//
//  IncidenceFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore
import FirebaseStorage

final class IncidenceFirestoreDataSource {
    
    private let client = FirestoreClient.shared
    
    // MARK: - Report
    func reportIncidence(_ incidence: Incidence) async throws -> Incidence {
        
        do {
            try await client.incidencesCollection
                .document(incidence.id)
                .setData(IncidenceMapper.toFirestore(incidence))
            
            return incidence
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Queries
    func getMyIncidences(userId: String) async throws -> [Incidence] {
        let query = client.incidencesCollection
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
        
        return try await fetchIncidences(query: query)
    }

    func getAllIncidences() async throws -> [Incidence] {
           try await fetchIncidences(query: client.incidencesCollection)
    }
    
    func getIncidenceDetail(incidenceId: String) async throws -> Incidence {
        do {
            let doc = try await client.incidencesCollection.document(incidenceId).getDocument()
            
            guard let data = doc.data() else {
                throw AppError.unknown("Incidence not found")
            }
            
            return try IncidenceMapper.toDomain(from: data, id: incidenceId)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Resolve
    func resolveIncidence(
        incidenceId: String,
        resolution: String,
        adminId: String
    ) async throws -> Incidence {
        do {
            try await client.incidencesCollection
                .document(incidenceId)
                .updateData([
                    "status": IncidenceStatus.resolved.rawValue,
                    "resolution": resolution,
                    "adminId": adminId,
                    "resolvedAt": Timestamp(date: Date())
                ])
            
            // Refrescamos los datos completos después de actualizar
            return try await getIncidenceDetail(incidenceId: incidenceId)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Private
    private func fetchIncidences(query: Query) async throws -> [Incidence] {
        do {
            let snapshot = try await query.getDocuments()
            
            return try snapshot.documents.map { document in
                try IncidenceMapper.toDomain(from: document.data(), id: document.documentID)
            }
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
}
