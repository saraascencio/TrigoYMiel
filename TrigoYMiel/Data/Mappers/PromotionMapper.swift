//
//  PromotionMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// MARK: - PromotionMapper
struct PromotionMapper {

    // MARK: Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> Promotion {

        // validar vigencia
        guard
            let startTS = data["startDate"] as? Timestamp,
            let endTS   = data["endDate"]   as? Timestamp
        else {
            throw AppError.decodingError
        }

        let description          = data["description"]          as? String   ?? ""
        let discountPercentage   = data["discountPercentage"]   as? Double   ?? 0.0
        let wholesaleOnly        = data["wholesaleOnly"]        as? Bool     ?? false
        let isActive             = data["isActive"]             as? Bool     ?? false
        let applicableProductIds = data["applicableProductIds"] as? [String] ?? []

        return Promotion(
            id:                   id,
            description:          description,
            discountPercentage:   discountPercentage,
            wholesaleOnly:        wholesaleOnly,
            startDate:            startTS.dateValue(),
            endDate:              endTS.dateValue(),
            isActive:             isActive,
            applicableProductIds: applicableProductIds
        )
    }

    // MARK: Domain → Firestore
    static func toFirestore(_ promotion: Promotion) -> [String: Any] {
        [
            "description":          promotion.description,
            "discountPercentage":   promotion.discountPercentage,
            "wholesaleOnly":        promotion.wholesaleOnly,
            "startDate":            Timestamp(date: promotion.startDate),
            "endDate":              Timestamp(date: promotion.endDate),
            "isActive":             promotion.isActive,
            "applicableProductIds": promotion.applicableProductIds
        ]
    }
}
