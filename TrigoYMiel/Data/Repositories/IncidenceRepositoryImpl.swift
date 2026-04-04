//
//  IncidenceRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

// MARK: - IncidenceRepositoryImpl
// Delega toda la lógica al IncidenceFirestoreDataSource (Firestore + Storage).

final class IncidenceRepositoryImpl: IncidenceRepository {

    private let remoteDataSource = IncidenceFirestoreDataSource()

    func reportIncidence(_ incidence: Incidence, evidenceImageData: Data?) async throws -> Incidence {
        try await remoteDataSource.reportIncidence(incidence, evidenceImageData: evidenceImageData)
    }

    func getMyIncidences(userId: String) async throws -> [Incidence] {
        try await remoteDataSource.getMyIncidences(userId: userId)
    }

    func getAllIncidences() async throws -> [Incidence] {
        try await remoteDataSource.getAllIncidences()
    }

    func getIncidenceDetail(incidenceId: String) async throws -> Incidence {
        try await remoteDataSource.getIncidenceDetail(incidenceId: incidenceId)
    }

    func resolveIncidence(incidenceId: String, resolution: String, adminId: String) async throws -> Incidence {
        try await remoteDataSource.resolveIncidence(
            incidenceId: incidenceId, resolution: resolution, adminId: adminId
        )
    }
}
