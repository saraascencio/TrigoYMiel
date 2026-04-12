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
    @Published var products:       [Product]         = []
    @Published var categoriesList: [ProductCategory] = []
    @Published var categoriesMap:  [String: String]  = [:]
    @Published var isLoading:      Bool              = false
    @Published var errorMessage:   String?           = nil

    // MARK: - Filtros
    @Published var searchText:       String  = ""
    @Published var selectedCategory: String? = nil

    // MARK: - Sheet
    @Published var productToEdit:   Product? = nil
    @Published var showCreateSheet: Bool     = false
    @Published var showEditSheet:   Bool     = false

    // MARK: - Dependencies
    private let getProductsUseCase:    GetProductsUseCase
    private let searchProductsUseCase: SearchProductsUseCase

    init(
        getProductsUseCase:    GetProductsUseCase,
        searchProductsUseCase: SearchProductsUseCase
    ) {
        self.getProductsUseCase    = getProductsUseCase
        self.searchProductsUseCase = searchProductsUseCase
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
    // MARK: - Actions

    func loadProducts() async {
        isLoading    = true
        errorMessage = nil
        do {
            let prods = try await getProductsUseCase.execute()
            let cats  = try await ProductRepositoryImpl().getAllCategories()
            products      = prods
            categoriesList = cats
            categoriesMap  = Dictionary(uniqueKeysWithValues: cats.map { ($0.id, $0.name) })
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

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

    func deleteProduct(_ product: Product) async {
        do {
        
            try await DeleteProductUseCase(
                productRepository: ProductRepositoryImpl()
            ).execute(productId: product.id)
            
           
            if let index = products.firstIndex(where: { $0.id == product.id }) {
                let old = products[index]
                
                
                let updatedProduct = Product(
                    id: old.id,
                    name: old.name,
                    description: old.description,
                    ingredients: old.ingredients,
                    unitPrice: old.unitPrice,
                    stock: old.stock,
                    isAvailable: false,
                    categoryId: old.categoryId,
                    imageURL: old.imageURL,
                    isPopular: old.isPopular
                )
                
            
                products[index] = updatedProduct
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
}
