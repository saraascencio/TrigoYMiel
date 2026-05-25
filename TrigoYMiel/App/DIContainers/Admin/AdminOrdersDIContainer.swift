//
//  AdminOrdersDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 8/4/26.
//
import Foundation

final class AdminOrdersDIContainer {

    private let orderRepository: OrderRepository = OrderRepositoryImpl()
    private let productRepository: ProductRepository = ProductRepositoryImpl()
    
    func makeGetAllOrdersUseCase() -> GetAllOrdersUseCase {
        GetAllOrdersUseCase(orderRepository: orderRepository)
    }

    func makeUpdateOrderStatusUseCase() -> UpdateOrderStatusUseCase {
            
            UpdateOrderStatusUseCase(
                orderRepository: orderRepository,
                productRepository: productRepository
            )
    }
    
    func makeAdminOrdersViewModel() -> AdminOrdersViewModel {
        AdminOrdersViewModel(
            getAllOrdersUseCase:      makeGetAllOrdersUseCase(),
            updateOrderStatusUseCase: makeUpdateOrderStatusUseCase()
        )
    }
}
