//
//  GetCartUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 15/4/26.
//
// Domain/UseCases/Cart/GetCartUseCase.swift

import Foundation

// MARK: - GetCartUseCase
// Obtiene el carrito actual del usuario desde el repositorio.

final class GetCartUseCase {
    private let cartRepository: CartRepository
    
    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }
    
    func execute(userId: String) async throws -> [CartItem] {
        // Corregido: el método del protocolo es getCartItems y el parámetro es userId
        try await cartRepository.getCartItems(userId: userId)
    }
}
