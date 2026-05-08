//
//  MyIncidencesViewModel.swift
//  TrigoYMiel
//
//  Created by Walter Gonzalez on 7/5/26.
//
//  ViewModel de la pantalla "Mis reportes" (historial de incidencias del cliente).
//  Consume GetMyIncidencesUseCase y expone los datos a MyIncidencesView.

import Foundation
import SwiftUI
import Combine

@MainActor
final class MyIncidencesViewModel: ObservableObject {

    // MARK: - Estado publicado
    @Published var incidences: [Incidence]  = []
    @Published var isLoading: Bool          = false
    @Published var errorMessage: String?    = nil

    // MARK: - Dependencias
    private let getMyIncidencesUseCase: GetMyIncidencesUseCase
    let currentUser: User

    // MARK: - Init
    init(currentUser: User, getMyIncidencesUseCase: GetMyIncidencesUseCase) {
        self.currentUser             = currentUser
        self.getMyIncidencesUseCase  = getMyIncidencesUseCase
    }

    // MARK: - Carga
    func loadIncidences() async {
        isLoading    = true
        errorMessage = nil
        do {
            incidences = try await getMyIncidencesUseCase.execute(userId: currentUser.id)
        } catch let appError as AppError {
            errorMessage = appError.errorDescription
        } catch {
            errorMessage = "No se pudieron cargar tus reportes. Intenta de nuevo."
        }
        isLoading = false
    }

    // MARK: - Helpers de presentación
    var openCount: Int     { incidences.filter { $0.status == .open }.count }
    var resolvedCount: Int { incidences.filter { $0.status == .resolved }.count }
}
