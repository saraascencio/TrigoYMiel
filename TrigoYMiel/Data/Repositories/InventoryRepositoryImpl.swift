//
//  InventoryRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

// MARK: - InventoryRepositoryImpl
// Delega al InventoryFirestoreDataSource que usa transacciones atómicas.

final class InventoryRepositoryImpl: InventoryRepository {

    private let remoteDataSource = InventoryFirestoreDataSource()

    func getInventory() async throws -> [InventoryEntry] {
        try await remoteDataSource.getInventory()
    }

    func registerEntry(productId: String, quantity: Int, note: String, adminId: String) async throws -> InventoryMovement {
        try await remoteDataSource.registerEntry(
            productId: productId, quantity: quantity, note: note, adminId: adminId
        )
    }

    func registerExit(productId: String, quantity: Int, note: String, adminId: String) async throws -> InventoryMovement {
        try await remoteDataSource.registerExit(
            productId: productId, quantity: quantity, note: note, adminId: adminId
        )
    }

    func getMovements(productId: String) async throws -> [InventoryMovement] {
        try await remoteDataSource.getMovements(productId: productId)
    }
}
