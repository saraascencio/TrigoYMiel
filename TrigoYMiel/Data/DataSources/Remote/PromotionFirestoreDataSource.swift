//
//  PromotionFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore


// Maneja la colección "promotions" en Firestore.
final class PromotionFirestoreDataSource {
    
    private let client = FirestoreClient.shared
    
    func getActivePromotions() async throws -> [Promotion] {
        do {
            let snapshot = try await client.promotionsCollection
                .whereField("isActive", isEqualTo: true)
                .getDocuments()
            
            return try snapshot.documents.map { doc in
                try PromotionMapper.toDomain(
                    from: doc.data(),
                    id: doc.documentID
                )
            }
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    func getPromotions(forProduct productId: String) async throws -> [Promotion] {
        do {
            let snapshot = try await client.promotionsCollection
                .whereField("isActive", isEqualTo: true)
                .whereField("applicableProductIds", arrayContains: productId) 
                .getDocuments()
            
            return try snapshot.documents.map { doc in
                try PromotionMapper.toDomain(
                    from: doc.data(),
                    id: doc.documentID
                )
            }
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
}
