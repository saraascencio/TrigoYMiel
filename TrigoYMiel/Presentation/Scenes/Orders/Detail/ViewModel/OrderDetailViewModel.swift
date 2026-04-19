//
//  OrderDetailViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class OrderDetailViewModel: ObservableObject {
    
    @Published var order: Order
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showCancelAlert: Bool = false
    
 
    private let updateOrderStatusUseCase: UpdateOrderStatusUseCase
    
    init(order: Order, updateOrderStatusUseCase: UpdateOrderStatusUseCase) {
        self.order = order
        self.updateOrderStatusUseCase = updateOrderStatusUseCase
    }
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }
    
    func calculateSubtotal(price: Double, quantity: Int) -> String {
        let total = price * Double(quantity)
        return formatCurrency(total)
    }
    
    func cancelOrder() async {
        isLoading = true
        errorMessage = nil
        
        do {

            let updatedOrder = try await updateOrderStatusUseCase.execute(
                orderId: order.id,
                newStatus: .cancelled
            )
            self.order = updatedOrder
        } catch {
            self.errorMessage = "Error al cancelar: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
