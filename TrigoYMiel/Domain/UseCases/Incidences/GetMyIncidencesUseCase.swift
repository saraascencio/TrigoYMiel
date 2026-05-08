//
//  GetMyIncidencesUseCase.swift
//  TrigoYMiel
//
//  Created by Walter Gonzalez on 7/5/26.
//
//  Caso de uso: el cliente obtiene sus propias incidencias.
//  Orden: abiertas primero (más urgentes), luego resueltas; dentro de cada grupo
//  las más recientes al inicio — mismo criterio que el admin en GetIncidencesUseCase.
//
//  Usado por: MyIncidencesViewModel → MyIncidencesView (tab Soporte)
 
import Foundation
 
final class GetMyIncidencesUseCase {
 
    private let incidenceRepository: IncidenceRepository
 
    init(incidenceRepository: IncidenceRepository) {
        self.incidenceRepository = incidenceRepository
    }
 
    func execute(userId: String) async throws -> [Incidence] {
        let incidences = try await incidenceRepository.getMyIncidences(userId: userId)
 
        return incidences.sorted {
            if $0.status == .open && $1.status == .resolved { return true }
            if $0.status == .resolved && $1.status == .open  { return false }
            return $0.createdAt > $1.createdAt
        }
    }
}
 
