//
//  ResolveIncidenceUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - ResolveIncidenceUseCase
// El admin marca una incidencia como resuelta y agrega su nota.
// Actualiza en Firestore: estado, resolucion, fecha_resolucion, admin_id.
//
// Usado por: IncidencesViewModel (IncidenceDetailView)

final class ResolveIncidenceUseCase {

    private let incidenceRepository: IncidenceRepository

    init(incidenceRepository: IncidenceRepository) {
        self.incidenceRepository = incidenceRepository
    }

    func execute(
        incidenceId: String,
        resolution: String,
        adminId: String
    ) async throws -> Incidence {

        guard !resolution.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.unknown("La nota de resolución no puede estar vacía.")
        }

        return try await incidenceRepository.resolveIncidence(
            incidenceId: incidenceId,
            resolution: resolution,
            adminId: adminId
        )
    }
}
