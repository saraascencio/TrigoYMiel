//
//  OrderRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

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
}
