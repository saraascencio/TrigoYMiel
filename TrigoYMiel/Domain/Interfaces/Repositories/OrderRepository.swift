//
//  OrderRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - OrderRepository
// Protocolo para operaciones sobre pedidos en Firestore.
// Tanto el cliente como el admin usan este repositorio,
// pero con distintos UseCases que controlan el acceso.

protocol OrderRepository {

    // MARK: - Cliente

    /// Crea un nuevo pedido en Firestore a partir del carrito actual.
    /// Incluye los _snap de cada item al momento de confirmar.
    /// Lanza: .networkUnavailable, .productNotAvailable
    func placeOrder(_ order: Order) async throws -> Order

    /// Devuelve los pedidos activos (no entregados) del cliente.
    /// Escucha en tiempo real para que el estado se actualice sin recargar.
    func getActiveOrders(userId: String) async throws -> [Order]

    /// Devuelve el historial de pedidos entregados del cliente.
    func getOrderHistory(userId: String) async throws -> [Order]

    /// Devuelve el detalle de un pedido específico.
    /// Lanza: .orderNotFound
    func getOrderDetail(orderId: String) async throws -> Order

    // MARK: - Admin

    /// Devuelve TODOS los pedidos del negocio (todos los clientes).
    /// Solo el admin puede llamar a este método.
    /// Lanza: .unauthorized
    func getAllOrders() async throws -> [Order]

    /// Actualiza el estado de un pedido.
    /// Solo el admin puede llamar a este método.
    /// Lanza: .unauthorized, .orderNotFound, .orderAlreadyDelivered
    func updateOrderStatus(orderId: String, newStatus: OrderStatus) async throws -> Order
}
