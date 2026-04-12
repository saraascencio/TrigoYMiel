//
//  OrderMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// MARK: - OrderMapper
struct OrderMapper {

    // MARK: Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> Order {

        // Campos críticos
        guard
            let userId    = data["userId"]    as? String,
            let createdTS = data["createdAt"] as? Timestamp,
            let pickupTS  = data["pickupDate"] as? Timestamp,
            let total     = data["total"]     as? Double
        else {
            throw AppError.decodingError
        }

        // Enums con fallback
        let statusRaw  = data["status"]    as? String ?? OrderStatus.pending.rawValue
        let status     = OrderStatus(rawValue: statusRaw)  ?? .pending

        let typeRaw    = data["orderType"] as? String ?? OrderType.retail.rawValue
        let orderType  = OrderType(rawValue: typeRaw)      ?? .retail

        // Campos opcionales con fallback
        let notes                = data["additionalNotes"]     as? String       ?? ""
        let requiresAdvanceNotice = data["requiresAdvanceNotice"] as? Bool      ?? false
        let itemsData            = data["items"]               as? [[String: Any]] ?? []
        let items                = itemsData.compactMap { try? orderItemToDomain(from: $0) }

        return Order(
            id:                    id,
            userId:                userId,
            createdAt:             createdTS.dateValue(),
            pickupDate:            pickupTS.dateValue(),
            status:                status,
            orderType:             orderType,
            total:                 total,
            additionalNotes:       notes,
            items:                 items,
            requiresAdvanceNotice: requiresAdvanceNotice
        )
    }

    static func orderItemToDomain(from data: [String: Any]) throws -> OrderItem {

        // Campos críticos del item
        guard
            let productId = data["productId"] as? String
        else {
            throw AppError.decodingError
        }

        let nameSnap  = data["nameSnap"]      as? String ?? ""
        let priceSnap = data["unitPriceSnap"] as? Double ?? 0.0
        let imageSnap = data["imageURLSnap"]  as? String ?? ""
        let quantity  = data["quantity"]      as? Int    ?? 0
        let subtotal  = data["subtotal"]      as? Double ?? 0.0

        return OrderItem(
            id:            UUID().uuidString,
            productId:     productId,
            nameSnap:      nameSnap,
            unitPriceSnap: priceSnap,
            imageURLSnap:  imageSnap,
            quantity:      quantity,
            subtotal:      subtotal
        )
    }

    // MARK: Domain → Firestore
    static func toFirestore(_ order: Order) -> [String: Any] {
        [
            "userId":                order.userId,
            "createdAt":             Timestamp(date: order.createdAt),
            "pickupDate":            Timestamp(date: order.pickupDate),
            "status":                order.status.rawValue,
            "orderType":             order.orderType.rawValue,
            "total":                 order.total,
            "additionalNotes":       order.additionalNotes,
            "items":                 order.items.map { orderItemToFirestore($0) },
            "requiresAdvanceNotice": order.requiresAdvanceNotice
        ]
    }

    static func orderItemToFirestore(_ item: OrderItem) -> [String: Any] {
        [
            "productId":     item.productId,
            "nameSnap":      item.nameSnap,
            "unitPriceSnap": item.unitPriceSnap,
            "imageURLSnap":  item.imageURLSnap,
            "quantity":      item.quantity,
            "subtotal":      item.subtotal
        ]
    }
}
