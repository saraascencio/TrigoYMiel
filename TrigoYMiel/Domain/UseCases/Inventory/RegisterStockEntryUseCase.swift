//
//  RegisterStockEntryUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - RegisterStockEntryUseCase
// El admin registra la llegada de mercancía.
// Incrementa el stock del producto y crea un movimiento tipo "entrada".
//
// Usado por: InventoryViewModel (StockMovementFormView en modo entrada)

final class RegisterStockEntryUseCase {

    private let inventoryRepository: InventoryRepository

    init(inventoryRepository: InventoryRepository) {
        self.inventoryRepository = inventoryRepository
    }

    func execute(
        productId: String,
        quantity: Int,
        note: String,
        adminId: String
    ) async throws -> InventoryMovement {

        guard quantity > 0 else {
            throw AppError.unknown("La cantidad debe ser mayor a cero.")
        }

        return try await inventoryRepository.registerEntry(
            productId: productId,
            quantity: quantity,
            note: note,
            adminId: adminId
        )
    }
}
