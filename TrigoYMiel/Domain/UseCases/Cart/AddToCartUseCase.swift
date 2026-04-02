//
//  AddToCartUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - AddToCartUseCase
// Agrega un producto al carrito después de validar los límites del tier.
// Si el producto ya está en el carrito, el repositorio incrementa su cantidad.
//
// Usado por: ProductDetailViewModel (botón "Añadir al carrito")

final class AddToCartUseCase {

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
        product: Product,
        quantity: Int,
        userId: String,
        currentCart: [CartItem],
        tier: ClientTier
    ) async throws {

        // Primero valida — si lanza, no se toca el carrito
        try validateCartLimits.execute(
            currentCart: currentCart,
            productToAdd: product,
            quantityToAdd: quantity,
            tier: tier
        )

        guard product.isInStock else {
            throw AppError.productNotAvailable
        }

        let cartItem = CartItem(
            id: UUID().uuidString,
            product: product,
            quantity: quantity
        )

        try await cartRepository.addItem(cartItem, userId: userId)
    }
}
