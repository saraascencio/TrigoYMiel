//
//  GetInventoryUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetInventoryUseCase
// El admin obtiene todos los productos con su stock actual.
// Ordena primero los productos con stock bajo (≤ 5 unidades)
// para que el admin los identifique de inmediato.
//
// Usado por: InventoryViewModel (Tab "Inventario" del admin)

final class GetInventoryUseCase {

    private let inventoryRepository: InventoryRepository

    init(inventoryRepository: InventoryRepository) {
        self.inventoryRepository = inventoryRepository
    }

    func execute() async throws -> [InventoryEntry] {
        let inventory = try await inventoryRepository.getInventory()

        // Stock bajo primero, luego alfabético
        return inventory.sorted {
            if $0.isLowStock && !$1.isLowStock { return true }
            if !$0.isLowStock && $1.isLowStock { return false }
            return $0.productName < $1.productName
        }
    }
}
