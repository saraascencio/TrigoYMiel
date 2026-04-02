//
//  IncidenceRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - IncidenceRepository
// Protocolo para operaciones sobre incidencias en Firestore.
// El cliente crea incidencias desde SupportView.
// El admin las gestiona desde IncidencesView e IncidenceDetailView.

protocol IncidenceRepository {

    // MARK: Cliente

    /// Crea una incidencia en Firestore.
    /// Si hay imagen, la sube a Firebase Storage y guarda la URL en evidencia_url.
    /// Lanza: .networkUnavailable
    func reportIncidence(
        _ incidence: Incidence,
        evidenceImageData: Data?
    ) async throws -> Incidence

    /// Incidencias del cliente autenticado.
    func getMyIncidences(userId: String) async throws -> [Incidence]

    // MARK: Admin

    /// Todas las incidencias del negocio. Solo admin.
    /// Lanza: .unauthorized
    func getAllIncidences() async throws -> [Incidence]

    /// Detalle de una incidencia específica. Solo admin.
    /// Lanza: .unauthorized
    func getIncidenceDetail(incidenceId: String) async throws -> Incidence

    /// Marca una incidencia como resuelta con nota del admin.
    /// Actualiza: estado, resolucion, fecha_resolucion, admin_id.
    /// Lanza: .unauthorized
    func resolveIncidence(
        incidenceId: String,
        resolution: String,
        adminId: String
    ) async throws -> Incidence
}
