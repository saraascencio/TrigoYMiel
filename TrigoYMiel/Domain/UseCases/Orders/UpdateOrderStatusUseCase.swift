//
//  UpdateOrderStatusUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - UpdateOrderStatusUseCase
// El admin cambia el estado de un pedido en Firestore.
// El cliente ve el cambio en tiempo real desde ActiveOrdersView.
//
// Usado por: AdminOrderDetailViewModel (OrderStatusPickerView)

final class UpdateOrderStatusUseCase {

    private let orderRepository: OrderRepository

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    func execute(orderId: String, newStatus: OrderStatus) async throws -> Order {
        try await orderRepository.updateOrderStatus(
            orderId: orderId,
            newStatus: newStatus
        )
    }
}
