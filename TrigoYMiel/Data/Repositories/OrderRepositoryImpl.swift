//
//  OrderRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
/*import Foundation

// MARK: - OrderRepositoryImpl
// Todos los pedidos se gestionan en Firestore.

final class OrderRepositoryImpl: OrderRepository {

    private let remoteDataSource = OrderFirestoreDataSource()

    func placeOrder(_ order: Order) async throws -> Order {
        try await remoteDataSource.placeOrder(order)
    }

    func getActiveOrders(userId: String) async throws -> [Order] {
        try await remoteDataSource.getActiveOrders(userId: userId)
    }

    func getOrderHistory(userId: String) async throws -> [Order] {
        try await remoteDataSource.getOrderHistory(userId: userId)
    }

    func getOrderDetail(orderId: String) async throws -> Order {
        try await remoteDataSource.getOrderDetail(orderId: orderId)
    }

    func getAllOrders() async throws -> [Order] {
        try await remoteDataSource.getAllOrders()
    }

    func updateOrderStatus(orderId: String, newStatus: OrderStatus) async throws -> Order {
        try await remoteDataSource.updateOrderStatus(orderId: orderId, newStatus: newStatus)
    }
}*/
import Foundation

// MARK: - OrderRepositoryImpl
// Implementación del repositorio que orquesta la lógica de datos de pedidos.
final class OrderRepositoryImpl: OrderRepository {

    private let remoteDataSource = OrderFirestoreDataSource()

    // MARK: - Métodos Existentes (Delegados al DataSource)

    func placeOrder(_ order: Order) async throws -> Order {
        try await remoteDataSource.placeOrder(order)
    }

    func getActiveOrders(userId: String) async throws -> [Order] {
        try await remoteDataSource.getActiveOrders(userId: userId)
    }

    func getOrderHistory(userId: String) async throws -> [Order] {
        try await remoteDataSource.getOrderHistory(userId: userId)
    }

    func getOrderDetail(orderId: String) async throws -> Order {
        try await remoteDataSource.getOrderDetail(orderId: orderId)
    }

    func getAllOrders() async throws -> [Order] {
        try await remoteDataSource.getAllOrders()
    }

    func updateOrderStatus(orderId: String, newStatus: OrderStatus) async throws -> Order {
        try await remoteDataSource.updateOrderStatus(orderId: orderId, newStatus: newStatus)
    }

    // MARK: - Nuevas Validaciones de Reglas de Negocio
    // Estas son las que faltaban para cumplir con el protocolo.

    /// Determina si el usuario tiene pedidos bloqueantes.
    func hasActiveOrder(userId: String) async throws -> Bool {
        // Aprovechamos el método que ya tienes para traer las activas
        let activeOrders = try await getActiveOrders(userId: userId)
        // Si la lista no está vacía, significa que tiene un pedido "En curso"
        return !activeOrders.isEmpty
    }

    /// Consulta a la fuente de datos cuántos pedidos ha realizado el usuario hoy.
    func getOrderCountToday(userId: String) async throws -> Int {
        // Delegamos al data source la responsabilidad de contar en Firestore
        try await remoteDataSource.getOrderCountToday(userId: userId)
    }
}
