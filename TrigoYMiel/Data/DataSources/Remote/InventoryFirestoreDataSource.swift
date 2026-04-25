//
//  InventoryFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// MARK: - InventoryFirestoreDataSource
// Maneja stock (en "productos") y movimientos (en "movimientos_inventario").
// Usa transacciones Firestore para garantizar atomicidad en entradas/salidas.
final class InventoryFirestoreDataSource {
    
    private let client = FirestoreClient.shared
    
    // MARK: - Inventory list
    func getInventory() async throws -> [InventoryEntry] {
        do {
            let snapshot = try await client.productsCollection.getDocuments()
            
            return try snapshot.documents.map { doc in
                let data = doc.data()
                let lastUpdated = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                
                return try InventoryMapper.entryToDomain(
                    from: data,
                    id: doc.documentID,
                    lastUpdated: lastUpdated
                )
            }
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Entry / Exit
    func registerEntry(productId: String, quantity: Int, note: String, adminId: String) async throws -> InventoryMovement {
        try await registerMovement(
            productId: productId,
            quantity: quantity,
            note: note,
            adminId: adminId,
            type: .entry
        )
    }
    
    func registerExit(productId: String, quantity: Int, note: String, adminId: String) async throws -> InventoryMovement {
        try await registerMovement(
            productId: productId,
            quantity: quantity,
            note: note,
            adminId: adminId,
            type: .exit
        )
    }
    
    // MARK: - Movement history
    func getMovements(productId: String) async throws -> [InventoryMovement] {
        do {
            let snapshot = try await client.inventoryMovementsCollection
                .whereField("productId", isEqualTo: productId)
                .order(by: "date", descending: true)
                .getDocuments()
            
            return try snapshot.documents.map { doc in
                try InventoryMapper.movementToDomain(
                    from: doc.data(),
                    id: doc.documentID
                )
            }
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Private: transacción atómica
    private func registerMovement(
        productId: String,
        quantity: Int,
        note: String,
        adminId: String,
        type: MovementType
    ) async throws -> InventoryMovement {
        
        let db = client.db
        let productRef = client.productsCollection.document(productId)
        let movRef = client.inventoryMovementsCollection.document()
        let now = Date()
        
        // Caja para capturar valores y errores desde el closure de la transacción
        final class TransactionResult {
            var resultingStock: Int = 0
            var appError: AppError?
        }
        
        let result = TransactionResult()
        
        do {
            
            _ = try await db.runTransaction { transaction, errorPointer -> Any? in
                
                // Leer el documento del producto actual
                let productSnap: DocumentSnapshot
                do {
                    productSnap = try transaction.getDocument(productRef)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }
                
                guard let data = productSnap.data(),
                      let currentStock = data["stock"] as? Int else {
                    result.appError = .productNotAvailable
                    errorPointer?.pointee = NSError(domain: "AppError", code: 0)
                    return nil
                }
                
                let newStock: Int
                switch type {
                case .entry:
                    newStock = currentStock + quantity
                case .exit:
                    guard currentStock >= quantity else {
                        result.appError = .insufficientStockForExit(available: currentStock)
                        errorPointer?.pointee = NSError(domain: "AppError", code: 1)
                        return nil
                    }
                    newStock = currentStock - quantity
                }
                
                result.resultingStock = newStock
                
                // Actualizar stock del producto
                transaction.updateData([
                    "stock": newStock,
                    "updatedAt": Timestamp(date: now)
                ], forDocument: productRef)
                
                // Crear el movimiento de inventario
                let movData: [String: Any] = [
                    "productId": productId,
                    "adminId": adminId,
                    "type": type.rawValue,
                    "quantity": quantity,
                    "resultingStock": newStock,
                    "note": note,
                    "date": Timestamp(date: now)
                ]
                
                transaction.setData(movData, forDocument: movRef)
                return nil
            }
        } catch {
            // Si ocurrió un error específico de la aplicación dentro de la transacción
            if let appErr = result.appError {
                throw appErr
            }
            throw AppError.firestoreError(error.localizedDescription)
        }
        
        // Transacción completada exitosamente → construir y retornar el movimiento
        return InventoryMovement(
            id: movRef.documentID,
            productId: productId,
            adminId: adminId,
            type: type,
            quantity: quantity,
            resultingStock: result.resultingStock,
            note: note,
            date: now
        )
    }
}
