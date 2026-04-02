//
//  GetAllOrdersUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetAllOrdersUseCase
// El admin obtiene todos los pedidos del negocio (todos los clientes),
// ordenados del más reciente al más antiguo.
//
// Usado por: AdminOrdersViewModel (Tab "Pedidos" del admin)

final class GetAllOrdersUseCase {

    private let orderRepository: OrderRepository

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    func execute() async throws -> [Order] {
        let orders = try await orderRepository.getAllOrders()
        return orders.sorted { $0.createdAt > $1.createdAt }
    }
}
