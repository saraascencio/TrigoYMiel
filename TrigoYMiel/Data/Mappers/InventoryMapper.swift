//
//  InventoryMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// MARK: - InventoryMapper
// Convierte entre [String: Any] de Firestore y los Domain Entities
// InventoryMovement e InventoryEntry.
struct InventoryMapper {
    
    // MARK: InventoryMovement: Firestore → Domain
    static func movementToDomain(from data: [String: Any], id: String) throws -> InventoryMovement {
        guard
            let productId = data["productId"] as? String,
            let adminId = data["adminId"] as? String,
            let typeRaw = data["type"] as? String,
            let type = MovementType(rawValue: typeRaw),
            let quantity = data["quantity"] as? Int,
            let resultingStock = data["resultingStock"] as? Int,
            let note = data["note"] as? String,
            let dateTS = data["date"] as? Timestamp
        else {
            throw AppError.decodingError
        }
        
        return InventoryMovement(
            id: id,
            productId: productId,
            adminId: adminId,
            type: type,
            quantity: quantity,
            resultingStock: resultingStock,
            note: note,
            date: dateTS.dateValue()
        )
    }
    
    // MARK: InventoryMovement: Domain → Firestore
    static func movementToFirestore(_ movement: InventoryMovement) -> [String: Any] {
        [
            "productId": movement.productId,
            "adminId": movement.adminId,
            "type": movement.type.rawValue,
            "quantity": movement.quantity,
            "resultingStock": movement.resultingStock,
            "note": movement.note,
            "date": Timestamp(date: movement.date)
        ]
    }
    
    // MARK: InventoryEntry: construido desde datos de producto
    static func entryToDomain(from data: [String: Any], id: String, lastUpdated: Date) throws -> InventoryEntry {
        guard
            let name = data["name"] as? String,
            let imageURL = data["imageURL"] as? String,
            let catId = data["categoryId"] as? String,
            let stock = data["stock"] as? Int
            //let isAvailable = data["isAvailable"] as? Bool opcional
        else {
            throw AppError.decodingError
        }
        
        return InventoryEntry(
            id: id,
            productName: name,
            imageURL: imageURL,
            categoryId: catId,
            currentStock: stock,
            lastUpdated: lastUpdated
        )
    }
}
