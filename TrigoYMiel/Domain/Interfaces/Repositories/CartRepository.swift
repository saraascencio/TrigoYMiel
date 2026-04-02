//
//  CartRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - CartRepository
// Protocolo para operaciones del carrito activo.
// El carrito vive SOLO en CoreData (offline-first).
// Se vacía cuando el cliente confirma el pedido (PlaceOrderUseCase).
// No hay colección de carritos en Firestore.

protocol CartRepository {

    /// Devuelve todos los ítems del carrito activo del usuario.
    func getCartItems(userId: String) async throws -> [CartItem]

    /// Agrega un ítem al carrito o incrementa su cantidad si ya existe.
    /// Nota: la validación de límites la hace ValidateCartLimitsUseCase ANTES de llamar aquí.
    func addItem(_ item: CartItem, userId: String) async throws

    /// Actualiza la cantidad de un ítem existente en el carrito.
    /// Si quantity llega a 0, elimina el ítem automáticamente.
    func updateItem(_ item: CartItem, userId: String) async throws

    /// Elimina un ítem del carrito por su productId.
    func removeItem(productId: String, userId: String) async throws

    /// Vacía completamente el carrito del usuario.
    /// Llamado por PlaceOrderUseCase al confirmar el pedido.
    func clearCart(userId: String) async throws
}
