//
//  OrderMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// MARK: - OrderMapper
// Convierte entre [String: Any] de Firestore y los Domain Entities Order / OrderItem.
// Los OrderItems se almacenan como array<map> embebido en el documento del pedido.
struct OrderMapper {
    
    // MARK: Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> Order {
        guard
            let userId = data["userId"] as? String,
            let createdTS = data["createdAt"] as? Timestamp,
            let pickupTS = data["pickupDate"] as? Timestamp,
            let statusRaw = data["status"] as? String,
            let status = OrderStatus(rawValue: statusRaw),
            let typeRaw = data["orderType"] as? String,
            let orderType = OrderType(rawValue: typeRaw),
            let total = data["total"] as? Double,
            let notes = data["additionalNotes"] as? String,
            let itemsData = data["items"] as? [[String: Any]],
            let requiresAdvanceNotice = data["requiresAdvanceNotice"] as? Bool
        else {
            throw AppError.decodingError
        }
        
        let items = try itemsData.map { try orderItemToDomain(from: $0) }
        
        return Order(
            id: id,
            userId: userId,
            createdAt: createdTS.dateValue(),
            pickupDate: pickupTS.dateValue(),
            status: status,
            orderType: orderType,
            total: total,
            additionalNotes: notes,
            items: items,
            requiresAdvanceNotice: requiresAdvanceNotice
        )
    }
    
    static func orderItemToDomain(from data: [String: Any]) throws -> OrderItem {
        guard
            let productId = data["productId"] as? String,
            let nameSnap = data["nameSnap"] as? String,
            let priceSnap = data["unitPriceSnap"] as? Double,
            let imageSnap = data["imageURLSnap"] as? String,
            let quantity = data["quantity"] as? Int,
            let subtotal = data["subtotal"] as? Double
        else {
            throw AppError.decodingError
        }
        
        return OrderItem(
            id: UUID().uuidString,   // ID local para SwiftUI (no viene de Firestore)
            productId: productId,
            nameSnap: nameSnap,
            unitPriceSnap: priceSnap,
            imageURLSnap: imageSnap,
            quantity: quantity,
            subtotal: subtotal
        )
    }
    
    // MARK: Domain → Firestore
    static func toFirestore(_ order: Order) -> [String: Any] {
        [
            "userId": order.userId,
            "createdAt": Timestamp(date: order.createdAt),
            "pickupDate": Timestamp(date: order.pickupDate),
            "status": order.status.rawValue,
            "orderType": order.orderType.rawValue,
            "total": order.total,
            "additionalNotes": order.additionalNotes,
            "items": order.items.map { orderItemToFirestore($0) },
            "requiresAdvanceNotice": order.requiresAdvanceNotice
        ]
    }
    
    static func orderItemToFirestore(_ item: OrderItem) -> [String: Any] {
        [
            "productId": item.productId,
            "nameSnap": item.nameSnap,
            "unitPriceSnap": item.unitPriceSnap,
            "imageURLSnap": item.imageURLSnap,
            "quantity": item.quantity,
            "subtotal": item.subtotal
        ]
    }
}
