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
    func reportIncidence(_ incidence: Incidence, evidenceImageData: Data?) async throws -> Incidence {
        var evidenceURL: String? = nil 
        

        if let imageData = evidenceImageData {
            evidenceURL = try await uploadEvidenceImage(imageData, incidenceId: incidence.id)
        }
        
        // Creamos el objeto final (por si quieres modificar algo antes de guardar)
        let finalIncidence = Incidence(
            id: incidence.id,
            userId: incidence.userId,
            orderId: incidence.orderId,
            adminId: incidence.adminId,
            type: incidence.type,
            channel: incidence.channel,
            description: incidence.description,
            evidenceURL: evidenceURL,
            createdAt: incidence.createdAt,
            status: incidence.status,
            resolution: incidence.resolution,
            resolvedAt: incidence.resolvedAt
        )
        
        do {
            try await client.incidencesCollection
                .document(finalIncidence.id)
                .setData(IncidenceMapper.toFirestore(finalIncidence))
            
            return finalIncidence
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
    
    // MARK: - Evidence Upload (descomentado y listo para usar)
    
    private func uploadEvidenceImage(_ data: Data, incidenceId: String) async throws -> String {
        let ref = client.storage.reference().child("incidences/\(incidenceId).jpg")
        do {
            _ = try await ref.putDataAsync(data, metadata: nil)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            throw AppError.unknown("Error uploading evidence: \(error.localizedDescription)")
        }
    }
    
}
