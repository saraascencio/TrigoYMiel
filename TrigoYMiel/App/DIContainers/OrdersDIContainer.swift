//
//  OrdersDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

final class OrderDIContainer {
    
    // MARK: - Dependencies
    // Necesario para que PlaceOrderUseCase pueda limpiar el carrito tras la compra
    private let cartRepository: CartRepository
    
    // Mantenemos una instancia única del repositorio de órdenes por eficiencia
    private lazy var orderRepository: OrderRepository = {
        return OrderRepositoryImpl()
    }()

    // MARK: - Initializer
    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }

    // MARK: - Repository Factory
    func makeOrderRepository() -> OrderRepository {
        return orderRepository
    }

    // MARK: - Use Cases (Cliente)
    
    /// Regla Trigo y Miel: Solo se dispara si el carrito tiene productos.
    func makePlaceOrderUseCase() -> PlaceOrderUseCase {
        return PlaceOrderUseCase(
            orderRepository: makeOrderRepository(),
            cartRepository: cartRepository
        )
    }
    
    /// Regla Trigo y Miel: Se usa para bloquear la compra si ya hay uno activo.
    func makeGetActiveOrdersUseCase() -> GetActiveOrdersUseCase {
        return GetActiveOrdersUseCase(orderRepository: makeOrderRepository())
    }
    
    func makeActiveOrdersViewModel(userId: String) -> ActiveOrdersViewModel {
            ActiveOrdersViewModel(
                userId:                userId,
                getActiveOrdersUseCase: makeGetActiveOrdersUseCase()
            )
    }
    
    func makeGetOrderHistoryUseCase() -> GetOrderHistoryUseCase {
        GetOrderHistoryUseCase(orderRepository: orderRepository)
    }

    func makeOrderHistoryViewModel(userId: String) -> OrderHistoryViewModel {
        OrderHistoryViewModel(
            userId:                userId,
            getOrderHistoryUseCase: makeGetOrderHistoryUseCase()
        )
    }
    
    
    func makeGetOrderDetailUseCase() -> GetOrderDetailUseCase {
        return GetOrderDetailUseCase(orderRepository: makeOrderRepository())
    }

    // MARK: - Use Cases (Admin)
    
    func makeGetAllOrdersUseCase() -> GetAllOrdersUseCase {
        return GetAllOrdersUseCase(orderRepository: makeOrderRepository())
    }
    
    func makeUpdateOrderStatusUseCase() -> UpdateOrderStatusUseCase {
        return UpdateOrderStatusUseCase(orderRepository: makeOrderRepository())
    }
}
