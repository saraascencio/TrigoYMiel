//
//  PromotionMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// MARK: - PromotionMapper
// Convierte entre [String: Any] de Firestore y el Domain Entity Promotion.
struct PromotionMapper {
    
    // MARK: Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> Promotion {
        guard
            let description = data["description"] as? String,
            let discountPercentage = data["discountPercentage"] as? Double,
            let wholesaleOnly = data["wholesaleOnly"] as? Bool,
            let startTS = data["startDate"] as? Timestamp,
            let endTS = data["endDate"] as? Timestamp,
            let isActive = data["isActive"] as? Bool,
            let applicableProductIds = data["applicableProductIds"] as? [String]
        else {
            throw AppError.decodingError
        }
        
        return Promotion(
            id: id,
            description: description,
            discountPercentage: discountPercentage,
            wholesaleOnly: wholesaleOnly,
            startDate: startTS.dateValue(),
            endDate: endTS.dateValue(),
            isActive: isActive,
            applicableProductIds: applicableProductIds
        )
    }
    
    // MARK: Domain → Firestore
    static func toFirestore(_ promotion: Promotion) -> [String: Any] {
        [
            "description": promotion.description,
            "discountPercentage": promotion.discountPercentage,
            "wholesaleOnly": promotion.wholesaleOnly,
            "startDate": Timestamp(date: promotion.startDate),
            "endDate": Timestamp(date: promotion.endDate),
            "isActive": promotion.isActive,
            "applicableProductIds": promotion.applicableProductIds
        ]
    }
}
