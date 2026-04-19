//
//  OrderHistoryViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class OrderHistoryViewModel: ObservableObject {

    // MARK: - State
    @Published var orders:       [Order] = []
    @Published var isLoading:    Bool    = false
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies
    private let userId:                  String
    private let getOrderHistoryUseCase:  GetOrderHistoryUseCase

    init(userId: String, getOrderHistoryUseCase: GetOrderHistoryUseCase) {
        self.userId                 = userId
        self.getOrderHistoryUseCase = getOrderHistoryUseCase
    }

    // MARK: - Actions

    func loadHistory() async {
        isLoading    = true
        errorMessage = nil
        do {
            orders = try await getOrderHistoryUseCase.execute(userId: userId)
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
