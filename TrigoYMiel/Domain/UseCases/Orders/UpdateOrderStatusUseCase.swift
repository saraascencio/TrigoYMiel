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
import Foundation

final class UpdateOrderStatusUseCase {

    private let orderRepository: OrderRepository
    private let productRepository: ProductRepository

    init(orderRepository: OrderRepository, productRepository: ProductRepository) {
        self.orderRepository = orderRepository
        self.productRepository = productRepository
    }

    func execute(orderId: String, newStatus: OrderStatus) async throws -> Order {
      
        let currentOrder = try await orderRepository.getOrderDetail(orderId: orderId)
        if newStatus == .delivered && currentOrder.status != .delivered {
           
            
            for item in currentOrder.items {
                
                try await productRepository.reduceStock(
                    productId: item.productId,
                    quantity: item.quantity
                )
            }
            
        }
    
        return try await orderRepository.updateOrderStatus(
            orderId: orderId,
            newStatus: newStatus
        )
    }
}
