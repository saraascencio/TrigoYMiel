//
//  ValidateCartLimitsUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation
// MARK: - ValidateCartLimitsUseCase
final class ValidateCartLimitsUseCase {
    
    private let cartRepository: CartRepository
    private let orderRepository: OrderRepository
    
    init(
        cartRepository: CartRepository,
        orderRepository: OrderRepository
    ) {
        self.cartRepository = cartRepository
        self.orderRepository = orderRepository
    }
    
    func execute(
        currentCart: [CartItem],
        productToAdd: Product,
        quantityToAdd: Int,
        tier: ClientTier,
        userId: String
    ) async throws {
  
        let hasActive = try await orderRepository.hasActiveOrder(userId: userId)
        if hasActive { throw AppError.orderInProgress }
        
        let countToday = try await orderRepository.getOrderCountToday(userId: userId)
        if countToday >= 3 { throw AppError.dailyLimitReached }
        

        if tier == .wholesale {
            if quantityToAdd < 75 || quantityToAdd > 100 {
                throw AppError.unknown("Para mayoristas, la cantidad debe ser entre 75 y 100 por producto.")
            }
        } else {
            if quantityToAdd < 1 || quantityToAdd > 74 {
                throw AppError.unknown("Para minoristas, la cantidad debe ser entre 1 y 74 unidades.")
            }
        }
        
    
        let existingItem = currentCart.first { $0.product.id == productToAdd.id }
        let totalUnitsForThisProduct = (existingItem?.quantity ?? 0) + quantityToAdd
        let maxAllowedPerProduct = (tier == .wholesale) ? 100 : 74
        
        if totalUnitsForThisProduct > maxAllowedPerProduct {
            throw AppError.unknown("Ya tienes \(existingItem?.quantity ?? 0) en el carrito. No puedes superar las \(maxAllowedPerProduct) unidades de este producto.")
        }
        
     
        let maxTotalUnits = (tier == .wholesale) ? 1000 : 74
        let currentTotalInCart = currentCart.reduce(0) { $0 + $1.quantity }
        if currentTotalInCart + quantityToAdd > maxTotalUnits {
            throw AppError.unknown("El total del pedido no puede superar las \(maxTotalUnits) unidades.")
        }
    }
}
