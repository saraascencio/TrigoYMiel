//
//  UpdateCartItemUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - UpdateCartItemUseCase
// Actualiza la cantidad de un ítem ya existente en el carrito.
// Si la nueva cantidad es 0, elimina el ítem automáticamente.
//
// Usado por: CartViewModel (selector +/- en CartView)

final class UpdateCartItemUseCase {

    private let cartRepository: CartRepository
    private let validateCartLimits: ValidateCartLimitsUseCase

    init(
        cartRepository: CartRepository,
        validateCartLimits: ValidateCartLimitsUseCase
    ) {
        self.cartRepository     = cartRepository
        self.validateCartLimits = validateCartLimits
    }

    func execute(
        item: CartItem,
        newQuantity: Int,
        userId: String,
        currentCart: [CartItem],
        tier: ClientTier
    ) async throws {

        guard newQuantity >= 0 else { return }

        // Si la nueva cantidad es 0, eliminar el ítem directamente
        if newQuantity == 0 {
            try await cartRepository.removeItem(productId: item.product.id, userId: userId)
            return
        }

        // Validar con el carrito sin el ítem actual para no doble-contar
        let cartWithoutCurrent = currentCart.filter { $0.product.id != item.product.id }
        try validateCartLimits.execute(
            currentCart: cartWithoutCurrent,
            productToAdd: item.product,
            quantityToAdd: newQuantity,
            tier: tier
        )

        let updatedItem = CartItem(
            id: item.id,
            product: item.product,
            quantity: newQuantity
        )
        try await cartRepository.updateItem(updatedItem, userId: userId)
    }
}
