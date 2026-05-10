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
        @Published var quantity: Int = 1
        @Published var isAddingToCart: Bool = false
        @Published var showSuccessMessage: Bool = false
        @Published var errorMessage: String? = nil
        @Published var isBlockedByOrder: Bool = false
        @Published var blockMessage: String? = nil
        @Published var activePromotions: [Promotion] = []
        
        // MARK: - Dependencies
        let product: Product
        let currentUser: User
        
        private let addToCartUseCase: AddToCartUseCase
        private let cartRepository: CartRepository
        private let orderRepository: OrderRepository
        private let promotionDataSource: PromotionFirestoreDataSource
        
        // MARK: - Computed
        var isWholesale: Bool { currentUser.tier == .wholesale }
        
        var totalPrice: Double {
            Double(quantity) * product.unitPrice
        }
        
        var totalPriceFormatted: String {
            String(format: "$%.2f", totalPrice)
        }
        
        var discountedTotal: Double {
            guard let promo = effectivePromotion else {
                return totalPrice
            }
            
            
            if promo.wholesaleOnly && quantity < 75 {
                return totalPrice
            }
            
            let discount = Double(promo.discountPercentage) / 100.0
            return totalPrice * (1 - discount)
        }
        
        var discountedTotalFormatted: String {
            String(format: "$%.2f", discountedTotal)
        }
        
        var savings: Double { totalPrice - discountedTotal }
        var savingsFormatted: String {
            String(format: "$%.2f", savings)
        }
        
  
    // MARK: - Promotion Logic
    var effectivePromotion: Promotion? {
        let now = Date()
        
        // Filtrar solo promociones válidas en tiempo
        let validPromos = activePromotions.filter { promo in
            promo.isActive &&
            promo.startDate <= now &&
            now <= promo.endDate
        }
        
        print("DEBUG effectivePromotion - Total validas: \(validPromos.count)") // ← DEBUG
        
        // Si es mayorista, busca primero las promociones mayoristas
        if isWholesale {
            if let wholesalePromo = validPromos.first(where: { $0.wholesaleOnly }) {
                print("DEBUG → Encontrada promo MAYORISTA: \(wholesalePromo.description) \(wholesalePromo.discountPercentage)%") // ← DEBUG
                return wholesalePromo
            }
            
            // Si no hay mayorista, devolvemos la mejor estándar
            return validPromos.max(by: { $0.discountPercentage < $1.discountPercentage })
        } else {
            // Minorista solo ve promociones estándar
            return validPromos.filter { !$0.wholesaleOnly }
                .max(by: { $0.discountPercentage < $1.discountPercentage })
        }
    }
    
        // MARK: - Init
        init(
            product: Product,
            currentUser: User,
            cartRepository: CartRepository,
            orderRepository: OrderRepository,
            addToCartUseCase: AddToCartUseCase,
            promotionDataSource: PromotionFirestoreDataSource
        ) {
            self.product = product
            self.currentUser = currentUser
            self.cartRepository = cartRepository
            self.orderRepository = orderRepository
            self.addToCartUseCase = addToCartUseCase
            self.promotionDataSource = promotionDataSource
            
            checkOrderingStatus()
            loadPromotion()
        }
        
    private func loadPromotion() {
        Task {
            do {
                let promos = try await promotionDataSource.getPromotions(forProduct: product.id)
                
                await MainActor.run {
                    self.activePromotions = promos
                }
            } catch {
                print("Error cargando promo: \(error)")
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

    func addToCart() {
        guard canAddToCart else { return }
        isAddingToCart = true
        errorMessage = nil
        
        Task {
            do {
               
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
              
                let rawMessage = error.errorDescription ?? "Límite de compra alcanzado"
                
            
                let cleanMessage = rawMessage
                    .replacingOccurrences(of: "Error inesperado:", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Error inesperado", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Unknown error:", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "Unknown error", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "unknown", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
               
                self.errorMessage = cleanMessage.prefix(1).uppercased() + cleanMessage.dropFirst()
            }
            catch {
             
                errorMessage = "Error de red: Inténtalo más tarde."
            }
            isAddingToCart = false
        }
    }
    
    
    var canAddToCart: Bool {
            let hasStock = product.stock >= quantity
            let isPositive = quantity > 0
            
            if isWholesale {
                return isPositive && quantity <= 100 && hasStock && !isAddingToCart
            } else {
                return isPositive && quantity <= 74 && hasStock && !isAddingToCart
            }
        }
        
        func commitQuantity() {
            let minAllowed = product.stock > 0 ? 1 : 0
            let maxAllowed = isWholesale ? 100 : 74
            let finalMax = min(maxAllowed, product.stock)
            
            if quantity < minAllowed {
                quantity = minAllowed
            } else if quantity > finalMax && finalMax > 0 {
                quantity = finalMax
            }
        }
    
}
