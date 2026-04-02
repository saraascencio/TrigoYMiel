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

final class ValidateCartLimitsUseCase {

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
}
