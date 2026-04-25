//
//  AdminInventoryDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 9/4/26.
//
import Foundation

final class AdminInventoryDIContainer {

    private let inventoryRepository: InventoryRepository = InventoryRepositoryImpl()

    func makeGetInventoryUseCase() -> GetInventoryUseCase {
        GetInventoryUseCase(inventoryRepository: inventoryRepository)
    }

    func makeRegisterStockEntryUseCase() -> RegisterStockEntryUseCase {
        RegisterStockEntryUseCase(inventoryRepository: inventoryRepository)
    }

    func makeRegisterStockExitUseCase() -> RegisterStockExitUseCase {
        RegisterStockExitUseCase(inventoryRepository: inventoryRepository)
    }

    func makeInventoryViewModel() -> InventoryViewModel {
        InventoryViewModel(
            getInventoryUseCase:       makeGetInventoryUseCase(),
            registerStockEntryUseCase: makeRegisterStockEntryUseCase(),
            registerStockExitUseCase:  makeRegisterStockExitUseCase()
        )
    }
}

