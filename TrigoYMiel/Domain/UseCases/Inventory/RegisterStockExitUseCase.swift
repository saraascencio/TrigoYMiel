//
//  RegisterStockExitUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - RegisterStockExitUseCase
// El admin registra una merma o ajuste manual de stock.
// Reduce el stock del producto y crea un movimiento tipo "salida".
// El repositorio valida que el stock resultante no sea negativo.
//
// Usado por: InventoryViewModel (StockMovementFormView en modo salida)

final class RegisterStockExitUseCase {

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

        return try await inventoryRepository.registerExit(
            productId: productId,
            quantity: quantity,
            note: note,
            adminId: adminId
        )
    }
}
