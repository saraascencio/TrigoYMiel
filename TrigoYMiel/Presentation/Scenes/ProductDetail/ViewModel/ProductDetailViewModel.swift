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
        guard let promo = activePromotion, quantity >= 75 else { return totalPrice }
        return totalPrice * (1 - promo.discountPercentage / 100)
    }

    var discountedTotalFormatted: String {
        String(format: "$%.2f", discountedTotal)
    }

    var savings: Double { totalPrice - discountedTotal }

    var savingsFormatted: String {
        String(format: "$%.2f", savings)
    }

    var canAddToCart: Bool {
        quantity > 0 && !isAddingToCart
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
        if currentUser.tier == .wholesale {
            loadPromotion()
        }
    }

    // MARK: - Carga promoción del producto

    private func loadPromotion() {
        Task {
            do {
                let promos = try await promotionDataSource
                    .getPromotions(forProduct: product.id)
                activePromotion = promos.first {
                    $0.isCurrentlyValid && $0.wholesaleOnly
                }
            } catch {
                // Sin promoción — no es error crítico
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
            } catch let error as AppError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Error al conectar con el carrito"
            }
            isAddingToCart = false
        }
    }
}
