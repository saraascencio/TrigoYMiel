//
//  SupportViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - SupportViewModel
// Maneja el estado de la pantalla de Contacto y ayuda.
// El cliente selecciona canal, tipo de incidencia, pedido relacionado,
// escribe una descripción y opcionalmente adjunta una foto.
// Llama a ReportIncidenceUseCase al enviar.

@MainActor
final class SupportViewModel: ObservableObject {

    // MARK: - Inputs del formulario
    @Published var selectedChannel: ContactChannel = .chat
    @Published var selectedType: IncidenceType = .incompleteOrder
    @Published var selectedOrder: Order? = nil
    @Published var description: String = ""
    @Published var selectedImageData: Data? = nil

    // MARK: - Estado de UI
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var didSubmitSuccessfully: Bool = false
    @Published var showImagePicker: Bool = false

    // Pedidos del cliente para el selector "Seleccionar pedido relacionado"
    @Published var orders: [Order] = []

    // MARK: - Límite de descripción
    let descriptionLimit = 500
    var descriptionRemaining: Int { descriptionLimit - description.count }

    // MARK: - UseCases
    private let reportIncidenceUseCase: ReportIncidenceUseCase
    private let getOrderHistoryUseCase: GetOrderHistoryUseCase
    private let getActiveOrdersUseCase: GetActiveOrdersUseCase

    // Usuario activo — inyectado desde el coordinator
    let currentUser: User

    // MARK: - Init
    init(
        currentUser: User,
        reportIncidenceUseCase: ReportIncidenceUseCase,
        getOrderHistoryUseCase: GetOrderHistoryUseCase,
        getActiveOrdersUseCase: GetActiveOrdersUseCase
    ) {
        self.currentUser              = currentUser
        self.reportIncidenceUseCase   = reportIncidenceUseCase
        self.getOrderHistoryUseCase   = getOrderHistoryUseCase
        self.getActiveOrdersUseCase   = getActiveOrdersUseCase
    }

    // MARK: - Load orders
    // Carga los pedidos del cliente para poblar el selector de pedido relacionado.
    // Combina pedidos activos e historial para dar opciones completas.
    func loadOrders() async {
        do {
            let active  = try await getActiveOrdersUseCase.execute(userId: currentUser.id)
            let history = try await getOrderHistoryUseCase.execute(userId: currentUser.id)
            orders = active + history
            // Seleccionar el primero por defecto si hay pedidos
            if selectedOrder == nil {
                selectedOrder = orders.first
            }
        } catch {
            // Si falla la carga de pedidos no bloqueamos el formulario
            orders = []
        }
    }

    // MARK: - Submit
    func submitIncidence() async {
        guard validateForm() else { return }
        guard let order = selectedOrder else {
            errorMessage = "Selecciona un pedido relacionado."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await reportIncidenceUseCase.execute(
                userId: currentUser.id,
                orderId: order.id,
                type: selectedType,
                channel: selectedChannel,
                description: description,
                evidenceImageData: selectedImageData
            )
            didSubmitSuccessfully = true
            resetForm()
        } catch let appError as AppError {
            errorMessage = appError.errorDescription
        } catch {
            errorMessage = "Error inesperado. Intenta de nuevo."
        }

        isLoading = false
    }

    // MARK: - Validation
    private func validateForm() -> Bool {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "La descripción no puede estar vacía."
            return false
        }
        guard trimmed.count <= descriptionLimit else {
            errorMessage = "La descripción no puede superar \(descriptionLimit) caracteres."
            return false
        }
        return true
    }

    // MARK: - Reset
    private func resetForm() {
        description       = ""
        selectedImageData = nil
        selectedChannel   = .chat
        selectedType      = .incompleteOrder
        selectedOrder     = orders.first
    }
}
