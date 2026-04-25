//
//  CartRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

// MARK: - CartRepositoryImpl
// El carrito vive exclusivamente en CoreData (offline-first).
// PlaceOrderUseCase se encarga de llamar a clearCart al confirmar el pedido.
final class CartRepositoryImpl: CartRepository {
    
    private let localDataSource = CartCoreDataSource()
    
    func getCartItems(userId: String) async throws -> [CartItem] {
        try localDataSource.getCartItems(userId: userId)
    }
    
    func addItem(_ item: CartItem, userId: String) async throws {
        try localDataSource.addItem(item, userId: userId)
    }
    
    func updateItem(_ item: CartItem, userId: String) async throws {
        try localDataSource.updateItem(item, userId: userId)
    }
    
    func removeItem(productId: String, userId: String) async throws {
        try localDataSource.removeItem(productId: productId, userId: userId)
    }
    
    func clearCart(userId: String) async throws {
        try localDataSource.clearCart(userId: userId)
    }
}
