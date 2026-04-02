//
//  RemoveFromCartUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - RemoveFromCartUseCase
// Elimina un ítem del carrito directamente (botón de papelera en CartView).
// No requiere validación de límites porque siempre reduce el carrito.
//
// Usado por: CartViewModel

final class RemoveFromCartUseCase {

    private let cartRepository: CartRepository

    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }

    func execute(productId: String, userId: String) async throws {
        try await cartRepository.removeItem(productId: productId, userId: userId)
    }
}
