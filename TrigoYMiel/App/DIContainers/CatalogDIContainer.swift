//
//  CatalogDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

final class CatalogDIContainer {
    
    private let productRepository: ProductRepository = ProductRepositoryImpl()
    
    
    private let authRepository: AuthRepository = AuthRepositoryImpl()
    
    // MARK: - Auth
    func makeAuthRepository() -> AuthRepository {
        return authRepository
    }
    
    // MARK: - Use Cases
    func makeGetProductsUseCase() -> GetProductsUseCase {
        GetProductsUseCase(productRepository: productRepository)
    }
    
    func makeGetPopularProductsUseCase() -> GetPopularProductsUseCase {
        GetPopularProductsUseCase(productRepository: productRepository)
    }
    
    func makeSearchProductsUseCase() -> SearchProductsUseCase {
        SearchProductsUseCase(productRepository: productRepository)
    }
    
    func makeGetProductsByCategoryUseCase() -> GetProductsByCategoryUseCase {
        GetProductsByCategoryUseCase(productRepository: productRepository)
    }
    
    // MARK: - ViewModel
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(
            authRepository: makeAuthRepository(),
            getProductsUseCase: makeGetProductsUseCase(),
            getPopularProductsUseCase: makeGetPopularProductsUseCase(),
            searchProductsUseCase: makeSearchProductsUseCase(),
            getProductsByCategoryUseCase: makeGetProductsByCategoryUseCase()
            
            
        )
    }
    
    func makeCreateProductUseCase() -> CreateProductUseCase {
            CreateProductUseCase(productRepository: productRepository)
    }

    func makeUpdateProductUseCase() -> UpdateProductUseCase {
            UpdateProductUseCase(productRepository: productRepository)
    }

    func makeDeleteProductUseCase() -> DeleteProductUseCase {
            DeleteProductUseCase(productRepository: productRepository)
    }
    
    func makeProductFormViewModel(
        mode:   ProductFormMode,
        onSave: @escaping (Product) -> Void
    ) -> ProductFormViewModel {
        ProductFormViewModel(
            mode:                 mode,
            createProductUseCase: makeCreateProductUseCase(),
            updateProductUseCase: makeUpdateProductUseCase(),
            deleteProductUseCase: makeDeleteProductUseCase(),
            onSave:               onSave
        )
    }
    
}
