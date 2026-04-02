//
//  GetActiveOrdersUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetActiveOrdersUseCase
// Devuelve los pedidos activos (no entregados) del cliente.
// Filtra en el Domain para garantizar que solo llegan pedidos
// con status.isActive == true, sin depender de filtros de Firestore.
//
// Usado por: ActiveOrdersViewModel (Tab "En curso" del cliente)

final class GetActiveOrdersUseCase {

    private let orderRepository: OrderRepository

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    func execute(userId: String) async throws -> [Order] {
        let orders = try await orderRepository.getActiveOrders(userId: userId)
        return orders
            .filter { $0.status.isActive }
            .sorted { $0.createdAt > $1.createdAt }
    }
}
