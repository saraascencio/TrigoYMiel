//
//  ActiveOrdersViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class ActiveOrdersViewModel: ObservableObject {

    // MARK: - State
    @Published var orders:       [Order] = []
    @Published var isLoading:    Bool    = false
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies
    private let userId:                 String
    private let getActiveOrdersUseCase: GetActiveOrdersUseCase

    init(userId: String, getActiveOrdersUseCase: GetActiveOrdersUseCase) {
        self.userId                 = userId
        self.getActiveOrdersUseCase = getActiveOrdersUseCase
    }

    // MARK: - Actions

    func loadOrders() async {
        isLoading    = true
        errorMessage = nil
        do {
            orders = try await getActiveOrdersUseCase.execute(userId: userId)
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
