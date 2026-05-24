//
//  AdminCatalogViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class AdminCatalogViewModel: ObservableObject {
    
    // MARK: - State
    @Published var products:        [Product]         = []
    @Published var categoriesList:  [ProductCategory] = []
    @Published var categoriesMap:   [String: String]  = [:]
    @Published var promotions:      [Promotion]       = []
    @Published var isLoading:       Bool              = false
    @Published var errorMessage:    String?           = nil
    
    // MARK: - Filtros
    @Published var searchText:       String  = ""
    @Published var selectedCategory: String? = nil
    
    // MARK: - Navigation — Producto
    @Published var productToEdit:    Product?  = nil
    @Published var showCreateSheet:  Bool      = false
    @Published var showEditSheet:    Bool      = false
    
    // MARK: - Navigation — Promoción
    @Published var showCreatePromo:  Bool      = false
    @Published var promotionToEdit:  Promotion? = nil
    @Published var showEditPromo:    Bool      = false
    
    // MARK: - Confirmar desactivar
    @Published var promoToDeactivate: Promotion? = nil
    @Published var showDeactivateAlert: Bool     = false
    
    // MARK: - Dependencies
    private let getProductsUseCase:    GetProductsUseCase
    private let searchProductsUseCase: SearchProductsUseCase
    private let promotionDataSource:   PromotionFirestoreDataSource
    
    init(
        getProductsUseCase:    GetProductsUseCase,
        searchProductsUseCase: SearchProductsUseCase,
        promotionDataSource:   PromotionFirestoreDataSource
    ) {
        self.getProductsUseCase    = getProductsUseCase
        self.searchProductsUseCase = searchProductsUseCase
        self.promotionDataSource   = promotionDataSource
    }
    
    // MARK: - Computed
    
    var filteredProducts: [Product] {
        var result = products.filter { $0.isAvailable }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let catId = selectedCategory {
            result = result.filter { $0.categoryId == catId }
        }
        return result
    }
    
    // MARK: - Load todo
    
    func loadAll() async {
        isLoading    = true
        errorMessage = nil
        do {
            async let prodsTask  = getProductsUseCase.execute()
            async let catsTask   = ProductRepositoryImpl().getAllCategories()
            async let promosTask = promotionDataSource.getActivePromotions()
            
            let (prods, cats, promos) = try await (prodsTask, catsTask, promosTask)
            
            products       = prods
            categoriesList = cats.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            categoriesMap = Dictionary(
                uniqueKeysWithValues: categoriesList.map { ($0.id, $0.name) }
            )
            promotions     = promos
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // Alias para compatibilidad con .task { await viewModel.loadProducts() }
    func loadProducts() async { await loadAll() }
    
    // MARK: - Producto CRUD
    
    func onProductSaved(_ product: Product, isNew: Bool) {
        if isNew {
            products.append(product)
        } else if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        }
        showCreateSheet = false
        showEditSheet   = false
        productToEdit   = nil
    }
    
    /*func deleteProduct(_ product: Product) async {
        do {
            try await DeleteProductUseCase(
                productRepository: ProductRepositoryImpl()
            ).execute(productId: product.id)
            
            if let index = products.firstIndex(where: { $0.id == product.id }) {
                let old = products[index]
                products[index] = Product(
                    id:          old.id,
                    name:        old.name,
                    description: old.description,
                    ingredients: old.ingredients,
                    unitPrice:   old.unitPrice,
                    stock:       old.stock,
                    isAvailable: false,
                    categoryId:  old.categoryId,
                    imageURL:    old.imageURL,
                    isPopular:   old.isPopular
                )
            }
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }*/
    
    func deleteProduct(_ product: Product) async {
        do {
            let updated = Product(
                id:          product.id,
                name:        product.name,
                description: product.description,
                ingredients: product.ingredients,
                unitPrice:   product.unitPrice,
                stock:       product.stock,
                isAvailable: false,
                categoryId:  product.categoryId,
                imageURL:    product.imageURL,
                isPopular:   product.isPopular
            )

            _ = try await UpdateProductUseCase(
                productRepository: ProductRepositoryImpl()
            ).execute(updated)

            if let index = products.firstIndex(where: { $0.id == product.id }) {
                products[index] = updated
            }

        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func selectCategory(_ categoryId: String?) {
        selectedCategory = categoryId
    }
    
    // MARK: - Promoción CRUD
    
    func onPromotionSaved(_ promotion: Promotion, isNew: Bool) {
        if isNew {
            promotions.append(promotion)
        } else if let index = promotions.firstIndex(where: { $0.id == promotion.id }) {
            promotions[index] = promotion
        }
        showCreatePromo = false
        showEditPromo   = false
        promotionToEdit = nil
    }
    
    func requestDeactivate(_ promotion: Promotion) {
        promoToDeactivate   = promotion
        showDeactivateAlert = true
    }
    
    func confirmDeactivate() async {
        guard let promo = promoToDeactivate,
              let id = promo.id else { return }
        
        do {
            try await promotionDataSource.deactivatePromotion(id: id)
            promotions.removeAll { $0.id == id }
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        promoToDeactivate = nil
        showDeactivateAlert = false
    }
}
