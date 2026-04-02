//
//  InventoryRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - InventoryRepository
// Protocolo para operaciones de inventario. Solo el admin interactúa aquí.
// Los movimientos se registran en "movimientos_inventario" y actualizan
// el campo "stock" del producto en "productos".

protocol InventoryRepository {

    /// Lista todos los productos con su stock actual. Solo admin.
    /// Lanza: .unauthorized
    func getInventory() async throws -> [InventoryEntry]

    /// Registra entrada de stock (mercancía que llega). Incrementa "stock".
    /// Crea documento en "movimientos_inventario" con tipo = "entrada".
    /// Lanza: .unauthorized, .productNotAvailable
    func registerEntry(
        productId: String,
        quantity: Int,
        note: String,
        adminId: String
    ) async throws -> InventoryMovement

    /// Registra salida de stock (merma o ajuste). Reduce "stock".
    /// Crea documento en "movimientos_inventario" con tipo = "salida".
    /// Lanza: .unauthorized, .insufficientStockForExit, .productNotAvailable
    func registerExit(
        productId: String,
        quantity: Int,
        note: String,
        adminId: String
    ) async throws -> InventoryMovement

    /// Historial de movimientos de un producto específico.
    func getMovements(productId: String) async throws -> [InventoryMovement]
}
