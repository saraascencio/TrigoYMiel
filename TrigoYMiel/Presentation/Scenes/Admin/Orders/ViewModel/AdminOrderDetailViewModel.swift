//
//  AdminOrderDetailViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class AdminOrderDetailViewModel: ObservableObject {

    @Published var isUpdating:    Bool    = false
    @Published var errorMessage:  String? = nil

    private let updateOrderStatusUseCase: UpdateOrderStatusUseCase

    init(updateOrderStatusUseCase: UpdateOrderStatusUseCase) {
        self.updateOrderStatusUseCase = updateOrderStatusUseCase
    }

    func updateStatus(_ order: Order, newStatus: OrderStatus) async -> Order? {
        isUpdating = true
        do {
            let updated = try await updateOrderStatusUseCase.execute(
                orderId:   order.id,
                newStatus: newStatus
            )
            isUpdating = false
            return updated
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isUpdating = false
        return nil
    }
}
