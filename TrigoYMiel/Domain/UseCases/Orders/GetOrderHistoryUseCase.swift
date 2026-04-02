//
//  GetOrderHistoryUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetOrderHistoryUseCase
// Devuelve el historial de pedidos entregados del cliente,
// ordenados del más reciente al más antiguo.
//
// Usado por: OrderHistoryViewModel (Tab "Historial" del cliente)

final class GetOrderHistoryUseCase {

    private let orderRepository: OrderRepository

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    func execute(userId: String) async throws -> [Order] {
        let orders = try await orderRepository.getOrderHistory(userId: userId)
        return orders
            .filter { $0.status.isCompleted }
            .sorted { $0.createdAt > $1.createdAt }
    }
}
