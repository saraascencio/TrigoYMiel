//
//  ValidateCartLimitsUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - ValidateCartLimitsUseCase
// ⚠️ El UseCase más crítico del Domain.
// Aplica las reglas de negocio de límites de carrito según el ClientTier.
// Debe ejecutarse SIEMPRE antes de AddToCartUseCase y UpdateCartItemUseCase.
//
// Reglas (definidas en ClientTier):
//   .retail    → máx 15 unidades/tipo | máx 5 tipos por pedido
//   .wholesale → máx 100 unidades/tipo | máx 10 tipos por pedido
//
// Esta lógica vive aquí en el Domain y nunca se duplica
// en ninguna View ni ViewModel.
//
// Usado por: AddToCartUseCase, UpdateCartItemUseCase
// MARK: - ValidateCartLimitsUseCase

/*final class ValidateCartLimitsUseCase {
    func execute(
        currentCart: [CartItem],
        productToAdd: Product,
        quantityToAdd: Int,
        tier: ClientTier

    ) throws {

        let maxUnitsPerType = tier.maxUnitsPerProductType
        let maxTypes        = tier.maxProductTypes

        // 1. Límite de unidades para este tipo de producto

        let existingItem    = currentCart.first { $0.product.id == productToAdd.id }
        let currentQuantity = existingItem?.quantity ?? 0
        let totalQuantity   = currentQuantity + quantityToAdd



        if totalQuantity > maxUnitsPerType {
            throw AppError.cartLimitExceeded(max: maxUnitsPerType)
        }
        // 2. Límite de tipos distintos de producto

        // Solo aplica si el producto NO está ya en el carrito (sería tipo nuevo)

        let isNewProductType = existingItem == nil
        if isNewProductType && currentCart.count >= maxTypes {
            throw AppError.maxProductTypesReached(max: maxTypes)

        }

    }

}*/
/*import Foundation

// MARK: - ValidateCartLimitsUseCase
final class ValidateCartLimitsUseCase {
    
    private let cartRepository: CartRepository
        private let orderRepository: OrderRepository // 1. Declarar
        private let validateCartLimits: ValidateCartLimitsUseCase

        init(
            cartRepository: CartRepository,
            orderRepository: OrderRepository, // 2. Agregar al init
            validateCartLimits: ValidateCartLimitsUseCase
        ) {
            self.cartRepository = cartRepository
            self.orderRepository = orderRepository // 3. Asignar
            self.validateCartLimits = validateCartLimits
        }
    
    func execute(
        currentCart: [CartItem],
        productToAdd: Product,
        quantityToAdd: Int,
        tier: ClientTier,
        userId: String
    ) async throws {

        // 1. Validar si hay un pedido en curso
        // Bloquea cualquier adición al carrito si el cliente ya tiene una orden activa.
        let hasActive = try await orderRepository.hasActiveOrder(userId: userId)
        if hasActive {
            throw AppError.orderInProgress
        }

        // 2. Validar límite de 3 pedidos por día
        // Control de flujo para evitar abuso de la plataforma y optimizar logística.
        let countToday = try await orderRepository.getOrderCountToday(userId: userId)
        if countToday >= 3 {
            throw AppError.dailyLimitReached
        }

        // 3. Validar límites de unidades por TIPO de producto
        // Minorista: 15 | Mayorista: 100
        let maxUnitsPerType = tier.maxUnitsPerProductType
        let existingItem = currentCart.first { $0.product.id == productToAdd.id }
        let totalUnitsForThisProduct = (existingItem?.quantity ?? 0) + quantityToAdd

        if totalUnitsForThisProduct > maxUnitsPerType {
            throw AppError.cartLimitExceeded(max: maxUnitsPerType)
        }

        // 4. Validar límite TOTAL de unidades en el carrito
        // Minorista: 75 totales | Mayorista: 1000 totales
        let maxTotalUnits = tier.maxTotalUnits
        let currentTotalInCart = currentCart.reduce(0) { $0 + $1.quantity }
        let newTotalPotential = currentTotalInCart + quantityToAdd
        
        if newTotalPotential > maxTotalUnits {
            // Reutilizamos el error de límite excedido o puedes crear uno específico
            throw AppError.unknown("El total del pedido (\(newTotalPotential)) supera el máximo permitido de \(maxTotalUnits) unidades.")
        }

        // 5. Validar límite de TIPOS de producto distintos
        // Minorista: 5 tipos | Mayorista: 10 tipos
        let isNewProductType = existingItem == nil
        if isNewProductType && currentCart.count >= tier.maxProductTypes {
            throw AppError.maxProductTypesReached(max: tier.maxProductTypes)
        }
    }
}*/
import Foundation

// MARK: - ValidateCartLimitsUseCase
final class ValidateCartLimitsUseCase {
    
    private let cartRepository: CartRepository   // si no lo usas, puedes quitarlo
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
        // 1. Pedido en curso
        let hasActive = try await orderRepository.hasActiveOrder(userId: userId)
        if hasActive {
            throw AppError.orderInProgress
        }
        
        // 2. Límite diario de pedidos
        let countToday = try await orderRepository.getOrderCountToday(userId: userId)
        if countToday >= 3 {
            throw AppError.dailyLimitReached
        }
        
        // 3. Límite por tipo de producto
        let maxUnitsPerType = tier.maxUnitsPerProductType
        let existingItem = currentCart.first { $0.product.id == productToAdd.id }
        let totalUnitsForThisProduct = (existingItem?.quantity ?? 0) + quantityToAdd
        
        if totalUnitsForThisProduct > maxUnitsPerType {
            throw AppError.cartLimitExceeded(max: maxUnitsPerType)
        }
        
        // 4. Límite total de unidades
        let maxTotalUnits = tier.maxTotalUnits
        let currentTotalInCart = currentCart.reduce(0) { $0 + $1.quantity }
        let newTotalPotential = currentTotalInCart + quantityToAdd
        
        if newTotalPotential > maxTotalUnits {
            throw AppError.unknown("El total del pedido (\(newTotalPotential)) supera el máximo permitido de \(maxTotalUnits) unidades.")
        }
        
        // 5. Límite de tipos de producto distintos
        let isNewProductType = existingItem == nil
        if isNewProductType && currentCart.count >= tier.maxProductTypes {
            throw AppError.maxProductTypesReached(max: tier.maxProductTypes)
        }
    }
}
