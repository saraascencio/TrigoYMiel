//
//  ProductDetailViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class ProductDetailViewModel: ObservableObject {

    // MARK: - State
    @Published var quantity:           Int     = 1
    @Published var isAddingToCart:     Bool    = false
    @Published var showSuccessMessage: Bool    = false
    @Published var errorMessage:       String? = nil
    @Published var isBlockedByOrder:   Bool    = false
    @Published var blockMessage:       String? = nil
    @Published var activePromotion:    Promotion? = nil

    // MARK: - Dependencies
    let product:     Product
    let currentUser: User

    private let addToCartUseCase:       AddToCartUseCase
    private let cartRepository:         CartRepository
    private let orderRepository:        OrderRepository
    private let promotionDataSource:    PromotionFirestoreDataSource

    // MARK: - Computed

    var isWholesale: Bool { currentUser.tier == .wholesale }

    var totalPrice: Double {
        Double(quantity) * product.unitPrice
    }

    var totalPriceFormatted: String {
        String(format: "$%.2f", totalPrice)
    }

    var discountedTotal: Double {
        guard let promo = activePromotion else { return totalPrice }
        
        // Si la promo es exclusiva de mayorista, validamos el mínimo de 75 unidades
        if promo.wholesaleOnly && quantity < 75 {
            return totalPrice
        }
        
        // Si es para todos (wholesaleOnly: false) o es mayorista cumpliendo el mínimo
        return totalPrice * (1 - (promo.discountPercentage / 100))
    }
    
    var discountedTotalFormatted: String {
        String(format: "$%.2f", discountedTotal)
    }

    var savings: Double { totalPrice - discountedTotal }

    var savingsFormatted: String {
        String(format: "$%.2f", savings)
    }

    // MARK: - Init

    init(
        product:             Product,
        currentUser:         User,
        cartRepository:      CartRepository,
        orderRepository:     OrderRepository,
        addToCartUseCase:    AddToCartUseCase,
        promotionDataSource: PromotionFirestoreDataSource
    ) {
        self.product             = product
        self.currentUser         = currentUser
        self.cartRepository      = cartRepository
        self.orderRepository     = orderRepository
        self.addToCartUseCase    = addToCartUseCase
        self.promotionDataSource = promotionDataSource

        checkOrderingStatus()
        loadPromotion()
    }

    // MARK: - Carga promoción del producto
    private func loadPromotion() {
        Task {
            do {
                let promos = try await promotionDataSource.getPromotions(forProduct: product.id)
                
                activePromotion = promos.first { promo in
                    let now = Date()
                    let isDateValid = promo.startDate <= now && now <= promo.endDate
                    
                    // LÓGICA DE VISIBILIDAD:
                    // Un minorista puede ver la promo SI (wholesaleOnly es falso).
                    // Un mayorista puede verla SIEMPRE (si es true o false).
                    let canView = !promo.wholesaleOnly || isWholesale
                    
                    return promo.isActive && isDateValid && canView
                }
            } catch {
                print("DEBUG: Error cargando promo: \(error)")
            }
        }
    }
    
    // MARK: - Verificar estado de pedidos

    func checkOrderingStatus() {
        Task {
            do {
                let hasActive  = try await orderRepository.hasActiveOrder(userId: currentUser.id)
                let countToday = try await orderRepository.getOrderCountToday(userId: currentUser.id)

                if hasActive {
                    isBlockedByOrder = true
                    blockMessage     = "Tienes un pedido en curso"
                } else if countToday >= 3 {
                    isBlockedByOrder = true
                    blockMessage     = "Límite de 3 pedidos diarios alcanzado"
                }
            } catch {
                print("Error verificando estatus: \(error)")
            }
        }
    }

    // MARK: - Añadir al carrito
    // 1. La validación de 'canAddToCart' para el botón
    // MARK: - Computed Properties
    var canAddToCart: Bool {
        // 1. Validación de stock: la cantidad pedida no puede superar el stock disponible
        let hasStock = product.stock >= quantity
        
        if isWholesale {
            // Mayorista: Rango exacto de 75 a 100 y que haya stock
            return quantity >= 75 && quantity <= 100 && hasStock && !isAddingToCart
        } else {
            // Minorista: Rango de 1 a 74 y que haya stock
            return quantity > 0 && quantity <= 74 && hasStock && !isAddingToCart
        }
    }

    // MARK: - Métodos
    func addToCart() {
        guard canAddToCart else { return }
        isAddingToCart = true
        errorMessage = nil

        Task {
            do {
                // Obtenemos el carrito actual para validar acumulados en el UseCase
                let currentItems = try await cartRepository.getCartItems(userId: currentUser.id)
                
                try await addToCartUseCase.execute(
                    product: product,
                    quantity: quantity,
                    userId: currentUser.id,
                    currentCart: currentItems,
                    tier: currentUser.tier
                )
                
                showSuccessMessage = true
                try? await Task.sleep(for: .seconds(1.5))
                showSuccessMessage = false
            }catch let error as AppError {
                // 1. Obtener el mensaje base
                let rawMessage = error.errorDescription ?? "Límite de compra alcanzado"
                
                // 2. Limpiar múltiples variantes de "Error inesperado" o "Unknown"
                let cleanMessage = rawMessage
                    .replacingOccurrences(of: "Error inesperado:", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Error inesperado", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Unknown error:", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Unknown error", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "unknown", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 3. Capitalizar la primera letra para que se vea bien
                self.errorMessage = cleanMessage.prefix(1).uppercased() + cleanMessage.dropFirst()
            }
            catch {
                // Error genérico de conexión o base de datos[cite: 1]
                errorMessage = "Error de red: Inténtalo más tarde."
            }
            isAddingToCart = false
        }
    }
    
    func commitQuantity() {
        // 1. Determinar límites según el Tier del usuario
        let minAllowed = isWholesale ? 75 : 1
        let maxAllowed = isWholesale ? 100 : 74
        
        // 2. Considerar el stock real como el techo definitivo
        let finalMax = min(maxAllowed, product.stock)
        
        // 3. Aplicar Clampeo (Asegurar que el valor esté en el rango permitido)
        // Si es menor al mínimo (incluyendo 0 o negativos), sube al mínimo.
        // Si es mayor al máximo permitido o stock, baja al máximo.
        let clamped = max(minAllowed, min(quantity, finalMax))
        
        // 4. Actualizar la propiedad publicada
        self.quantity = clamped
    }
}
