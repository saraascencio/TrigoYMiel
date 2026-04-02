//
//  GetIncidencesUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetIncidencesUseCase
// El admin obtiene todas las incidencias del negocio.
// Orden: primero las abiertas (más urgentes), luego las resueltas.
// Dentro de cada grupo, las más recientes primero.
//
// Usado por: IncidencesViewModel (Tab "Incidencias" del admin)

final class GetIncidencesUseCase {

    private let incidenceRepository: IncidenceRepository

    init(incidenceRepository: IncidenceRepository) {
        self.incidenceRepository = incidenceRepository
    }

    func execute() async throws -> [Incidence] {
        let incidences = try await incidenceRepository.getAllIncidences()

        return incidences.sorted {
            // Las abiertas van primero
            if $0.status == .open && $1.status == .resolved { return true }
            if $0.status == .resolved && $1.status == .open  { return false }
            // Dentro del mismo estado, más recientes primero
            return $0.createdAt > $1.createdAt
        }
    }
}
