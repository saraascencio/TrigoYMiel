//
//  PromotionFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

final class PromotionFirestoreDataSource {
    
    private let db = FirestoreClient.shared.db
    
    // MARK: - Leer promociones activas
    func getActivePromotions() async throws -> [Promotion] {
        let snapshot = try await db
            .collection("Promotion")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? PromotionMapper.toDomain(from: doc.data(), id: doc.documentID)
        }
    }
    
    // MARK: - Leer todas (activas e inactivas)
    func getAllPromotions() async throws -> [Promotion] {
        let snapshot = try await db
            .collection("Promotion")
            .order(by: "startDate", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? PromotionMapper.toDomain(from: doc.data(), id: doc.documentID)
        }
    }
    
    // MARK: - Promociones de un producto
    func getPromotions(forProduct productId: String) async throws -> [Promotion] {
        let snapshot = try await db
            .collection("Promotion")
            .whereField("applicableProductIds", arrayContains: productId)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? PromotionMapper.toDomain(from: doc.data(), id: doc.documentID)
        }
    }
    
    // MARK: - Crear
    func createPromotion(_ promotion: Promotion) async throws -> Promotion {
        let data = PromotionMapper.toFirestore(promotion)
        
       
        let ref = try await db
            .collection("Promotion")
            .addDocument(data: data)
        
        
        return Promotion(
            id:                   ref.documentID,
            description:          promotion.description,
            discountPercentage:   promotion.discountPercentage,
            wholesaleOnly:        promotion.wholesaleOnly,
            startDate:            promotion.startDate,
            endDate:              promotion.endDate,
            isActive:             promotion.isActive,
            applicableProductIds: promotion.applicableProductIds
        )
    }
    
    // MARK: - Actualizar
    func updatePromotion(_ promotion: Promotion) async throws {
        guard let id = promotion.id, !id.isEmpty else {
            throw AppError.decodingError
        }
        let data = PromotionMapper.toFirestore(promotion)
        try await db
            .collection("Promotion")
            .document(id)
            .updateData(data)
    }
    
    // MARK: - Desactivar (soft delete)
    func deactivatePromotion(id: String) async throws {
        guard !id.isEmpty else {
            throw AppError.decodingError
        }
        try await db
            .collection("Promotion")
            .document(id)
            .updateData(["isActive": false])
    }
}
