//
//  IncidencesViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class IncidencesViewModel: ObservableObject {

    // MARK: - State
    @Published var incidences:    [Incidence]        = []
    @Published var isLoading:     Bool               = false
    @Published var errorMessage:  String?            = nil
    @Published var userNamesMap:  [String: String]   = [:]

    // MARK: - Filtros
    @Published var searchText:     String              = ""
    @Published var selectedFilter: IncidenceTypeFilter = .all

    // MARK: - Detail
    @Published var selectedIncidence: Incidence? = nil
    @Published var isShowingDetail:   Bool       = false
    @Published var isResolving:       Bool       = false

    // MARK: - Dependencies
    private let getIncidencesUseCase:    GetIncidencesUseCase
    private let resolveIncidenceUseCase: ResolveIncidenceUseCase

    init(
        getIncidencesUseCase:    GetIncidencesUseCase,
        resolveIncidenceUseCase: ResolveIncidenceUseCase
    ) {
        self.getIncidencesUseCase    = getIncidencesUseCase
        self.resolveIncidenceUseCase = resolveIncidenceUseCase
    }

    // MARK: - Computed

    var filteredIncidences: [Incidence] {
        var result = incidences

        if !searchText.isEmpty {
            result = result.filter {
                // Busca por nombre del cliente usando el mapa
                let userName = userNamesMap[$0.userId] ?? ""
                return userName.localizedCaseInsensitiveContains(searchText) ||
                       $0.id.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch selectedFilter {
        case .all:             break
        case .incompleteOrder: result = result.filter { $0.type == .incompleteOrder }
        case .allergen:        result = result.filter { $0.type == .allergen }
        case .query:           result = result.filter { $0.type == .query }
        }

        return result
    }

    // MARK: - Actions

    func loadIncidences() async {
        isLoading    = true
        errorMessage = nil
        do {
            incidences = try await getIncidencesUseCase.execute()
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
        let uniqueUserIds = Set(incidences.map { $0.userId })
        for userId in uniqueUserIds {
            if let user = try? await AuthFirestoreDataSource().fetchUser(id: userId) {
                map[userId] = user.name
            }
        }
        userNamesMap = map
    }

    func resolveIncidence(
        incidenceId: String,
        resolution:  String,
        adminId:     String
    ) async {
        isResolving = true
        do {
            let resolved = try await resolveIncidenceUseCase.execute(
                incidenceId: incidenceId,
                resolution:  resolution,
                adminId:     adminId
            )
            if let index = incidences.firstIndex(where: { $0.id == resolved.id }) {
                incidences[index] = resolved
            }
            selectedIncidence = resolved
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isResolving = false
    }
}

// MARK: - IncidenceTypeFilter

enum IncidenceTypeFilter: String, CaseIterable {
    case all             = "Todas"
    case incompleteOrder = "Pedido incompleto"
    case allergen        = "Alérgeno"
    case query           = "Consulta"
}
