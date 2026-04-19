//
//  IncidencesDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Foundation

final class IncidencesDIContainer {

    private let incidenceRepository = IncidenceRepositoryImpl()
    private let orderRepository = OrderRepositoryImpl()

    func makeSupportViewModel(currentUser: User) -> SupportViewModel {
        return SupportViewModel(
            currentUser: currentUser,
            reportIncidenceUseCase: ReportIncidenceUseCase(incidenceRepository: incidenceRepository),
            getOrderHistoryUseCase: GetOrderHistoryUseCase(orderRepository: orderRepository),
            getActiveOrdersUseCase: GetActiveOrdersUseCase(orderRepository: orderRepository)
        )
    }
}
