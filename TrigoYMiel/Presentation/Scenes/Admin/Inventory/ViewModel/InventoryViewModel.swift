//
//  InventoryViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class InventoryViewModel: ObservableObject {

    // MARK: - State
    @Published var inventory:       [InventoryEntry] = []
    @Published var availabilityMap: [String: Bool]   = [:]
    @Published var isLoading:       Bool             = false
    @Published var errorMessage:    String?          = nil

    // MARK: - Filtros
    @Published var searchText:     String          = ""
    @Published var selectedFilter: InventoryFilter = .all

    // MARK: - Navigation
    @Published var isSubmitting: Bool = false

    // MARK: - Dependencies
    private let getInventoryUseCase:       GetInventoryUseCase
    private let registerStockEntryUseCase: RegisterStockEntryUseCase
    private let registerStockExitUseCase:  RegisterStockExitUseCase

    init(
        getInventoryUseCase:       GetInventoryUseCase,
        registerStockEntryUseCase: RegisterStockEntryUseCase,
        registerStockExitUseCase:  RegisterStockExitUseCase
    ) {
        self.getInventoryUseCase       = getInventoryUseCase
        self.registerStockEntryUseCase = registerStockEntryUseCase
        self.registerStockExitUseCase  = registerStockExitUseCase
    }

    // MARK: - Computed

    var filteredInventory: [InventoryEntry] {
        var result = inventory

        if !searchText.isEmpty {
            result = result.filter {
                $0.productName.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch selectedFilter {
        case .all:        break
        case .lowStock:   result = result.filter { $0.isLowStock && $0.currentStock > 0 }
        case .outOfStock: result = result.filter { $0.currentStock == 0 }
        }

        return result
    }

    // MARK: - Load

    func loadInventory() async {
        isLoading    = true
        errorMessage = nil
        do {
            inventory = try await getInventoryUseCase.execute()
            await loadAvailabilityMap()
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadAvailabilityMap() async {
        var map: [String: Bool] = [:]
        for entry in inventory {
            if let product = try? await ProductRepositoryImpl().getProduct(id: entry.id) {
                map[entry.id] = product.isAvailable
            }
        }
        availabilityMap = map
    }

    // MARK: - Entry

    func registerEntry(
        productId: String,
        quantity:  Int,
        note:      String,
        adminId:   String
    ) async {
        isSubmitting = true
        do {
            _ = try await registerStockEntryUseCase.execute(
                productId: productId,
                quantity:  quantity,
                note:      note,
                adminId:   adminId
            )
            await loadInventory()
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }

    // MARK: - Exit

    func registerExit(
        productId: String,
        quantity:  Int,
        note:      String,
        adminId:   String
    ) async {
        isSubmitting = true
        do {
            _ = try await registerStockExitUseCase.execute(
                productId: productId,
                quantity:  quantity,
                note:      note,
                adminId:   adminId
            )
            await loadInventory()
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }

    // MARK: - Toggle availability

    func toggleProductAvailability(_ entry: InventoryEntry) async {
        do {
            let product = try await ProductRepositoryImpl().getProduct(id: entry.id)
            let updated = Product(
                id:          product.id,
                name:        product.name,
                description: product.description,
                ingredients: product.ingredients,
                unitPrice:   product.unitPrice,
                stock:       product.stock,
                isAvailable: !product.isAvailable,
                categoryId:  product.categoryId,
                imageURL:    product.imageURL,
                isPopular:   product.isPopular
            )
            _ = try await UpdateProductUseCase(
                productRepository: ProductRepositoryImpl()
            ).execute(updated)
            availabilityMap[entry.id] = !product.isAvailable
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - InventoryFilter

enum InventoryFilter: String, CaseIterable {
    case all        = "Todos"
    case lowStock   = "Stock bajo"
    case outOfStock = "Agotados"
}
