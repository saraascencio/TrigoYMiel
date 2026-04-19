//
//  CatalogViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class CatalogViewModel: ObservableObject {
    
    // MARK: - State
    @Published var allProducts: [Product] = []
    @Published var popularProducts: [Product] = []
    @Published var categories: [ProductCategory] = []
    @Published var activePromotions: [Promotion] = []
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedCategory: ProductCategory? = nil
    
    @Published var searchText:        String  = ""
    @Published var isSearching:       Bool    = false
    @Published var searchResults:    [Product]         = []
    
    
    // MARK: - Dependencies
    private let authRepository: AuthRepository
    private let getProductsUseCase: GetProductsUseCase
    private let getPopularProductsUseCase: GetPopularProductsUseCase
    private let searchProductsUseCase: SearchProductsUseCase
    private let getProductsByCategoryUseCase: GetProductsByCategoryUseCase
    
    
    init(
        authRepository: AuthRepository,
        getProductsUseCase: GetProductsUseCase,
        getPopularProductsUseCase: GetPopularProductsUseCase,
        searchProductsUseCase: SearchProductsUseCase,
        getProductsByCategoryUseCase: GetProductsByCategoryUseCase
    ) {
        self.authRepository = authRepository
        self.getProductsUseCase = getProductsUseCase
        self.getPopularProductsUseCase = getPopularProductsUseCase
        self.searchProductsUseCase = searchProductsUseCase
        self.getProductsByCategoryUseCase = getProductsByCategoryUseCase
    }
    
    // MARK: - Computed
    var productsByCategory: [(category: ProductCategory, products: [Product])] {
        categories.compactMap { category in
       
            if let selected = selectedCategory, selected.id != category.id {
                return nil
            }
            
            let products = allProducts.filter {
                $0.categoryId == category.id && $0.isAvailable
            }
            
            guard !products.isEmpty else { return nil }
            return (category: category, products: products)
        }
    }
    
    func selectCategory(_ category: ProductCategory) {
        if selectedCategory?.id == category.id {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
    
    // MARK: - Actions
    func loadCatalog() async {
        isLoading = true
        errorMessage = nil
        do {
        
            async let productsTask = getProductsUseCase.execute()
            async let popularTask  = getPopularProductsUseCase.execute()
            async let catsTask     = ProductRepositoryImpl().getAllCategories()
            
       
            async let userTask     = authRepository.currentUser()
            async let promosTask   = ProductRepositoryImpl().getActivePromotions()
            
      
            let (products, popular, cats, user, promos) = try await (productsTask, popularTask, catsTask, userTask, promosTask)
            
            self.allProducts      = products.filter { $0.isAvailable }
            self.popularProducts  = popular
            self.categories       = cats.filter { $0.isActive }
            self.currentUser      = user
            self.activePromotions = promos
            
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func search() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            isSearching   = false
            return
        }
        isSearching = true
        do {
            searchResults = try await searchProductsUseCase.execute(query: trimmed)
        } catch {
            searchResults = allProducts.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed)
            }
        }
    }
    
    func clearSearch() {
        searchText    = ""
        searchResults = []
        isSearching   = false
    }
    
    // MARK: - Promociones (La lógica corregida)
    func isProductOnPromotion(product: Product) -> Bool {
    
        return activePromotions.contains { promotion in
            promotion.isActive &&
            promotion.wholesaleOnly &&
            promotion.applicableProductIds.contains(product.id) &&
            promotion.startDate <= Date() && Date() <= promotion.endDate
        }
    }
    
    func shouldShowPromotion(for product: Product) -> Bool {
       
        let isActuallyOnPromotion = isProductOnPromotion(product: product)
        let isWholesaleUser = currentUser?.tier == .wholesale
        return isActuallyOnPromotion && isWholesaleUser
    }
}
