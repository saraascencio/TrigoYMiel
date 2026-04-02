//
//  GetOrderDetailUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetOrderDetailUseCase
// Devuelve el detalle completo de un pedido específico.
// Accesible tanto desde ActiveOrdersView como desde OrderHistoryView.
//
// Usado por: OrderDetailViewModel

final class GetOrderDetailUseCase {

    private let orderRepository: OrderRepository

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    func execute(orderId: String) async throws -> Order {
        try await orderRepository.getOrderDetail(orderId: orderId)
    }
}
