//
//  AdminOrdersViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class AdminOrdersViewModel: ObservableObject {
    
    // MARK: - State
    @Published var orders:        [Order] = []
    @Published var isLoading:     Bool    = false
    @Published var errorMessage:  String? = nil
    @Published var userNamesMap: [String: String] = [:]
    
    // MARK: - Filtros
    @Published var searchText:    String      = ""
    @Published var selectedDate:  Date?       = nil
    @Published var selectedFilter: OrderFilter = .all
    
    // MARK: - Update sheet
    @Published var orderToUpdate: Order? = nil
    @Published var isUpdating:    Bool   = false
    
    // MARK: - Dependencies
    private let getAllOrdersUseCase:       GetAllOrdersUseCase
    private let updateOrderStatusUseCase: UpdateOrderStatusUseCase
    
    init(
        getAllOrdersUseCase:       GetAllOrdersUseCase,
        updateOrderStatusUseCase: UpdateOrderStatusUseCase
    ) {
        self.getAllOrdersUseCase       = getAllOrdersUseCase
        self.updateOrderStatusUseCase = updateOrderStatusUseCase
    }
    
    // MARK: - Computed: filtrado
    
    var filteredOrders: [Order] {
        var result = orders
        
        if !searchText.isEmpty {
            result = result.filter {
                let userName = userNamesMap[$0.userId]?.localizedCaseInsensitiveContains(searchText) ?? false
                let byId     = $0.displayId.localizedCaseInsensitiveContains(searchText)
                return userName || byId
            }
        }
        // Filtro por fecha
        if let date = selectedDate {
            let calendar = Calendar.current
            result = result.filter {
                calendar.isDate($0.pickupDate, inSameDayAs: date)
            }
        }
        
        // Filtro por tipo/estado
        switch selectedFilter {
        case .all:       break
        case .wholesale: result = result.filter { $0.orderType == .wholesale }
        case .pending:   result = result.filter { $0.status == .pending }
        case .confirmed: result = result.filter { $0.status == .inPreparation }
        case .ready:     result = result.filter { $0.status == .readyForPickup }
        }
        
        return result
    }
    
    // MARK: - Actions
    
    
    func updateStatus(_ order: Order, newStatus: OrderStatus) async {
        isUpdating = true
        do {
            let updated = try await updateOrderStatusUseCase.execute(
                orderId: order.id, newStatus: newStatus
            )
            if let index = orders.firstIndex(where: { $0.id == updated.id }) {
                orders[index] = updated
            }
            orderToUpdate = nil
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isUpdating = false
    }
    
    func clearDate() {
        selectedDate = nil
    }
    
    
    
    func loadOrders() async {
        isLoading    = true
        errorMessage = nil
        do {
            orders = try await getAllOrdersUseCase.execute()
            await loadUserNames()
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func loadUserNames() async {
        var map: [String: String] = [:]
        let uniqueUserIds = Set(orders.map { $0.userId })
        for userId in uniqueUserIds {
            if let user = try? await AuthFirestoreDataSource().fetchUser(id: userId) {
                map[userId] = user.name
            }
        }
        userNamesMap = map
    }
}

// MARK: - OrderFilter
enum OrderFilter: String, CaseIterable {
    case all       = "Todos"
    case wholesale = "Mayoreo"
    case pending   = "Pendiente"
    case confirmed = "Confirmado"
    case ready     = "Listo"
}
