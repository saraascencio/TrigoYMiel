//
//  AdminCatalogDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 8/4/26.
//
import Foundation

final class AdminCatalogDIContainer {
    
    private let productRepository: ProductRepository = ProductRepositoryImpl()
    private let promotionDataSource: PromotionFirestoreDataSource = PromotionFirestoreDataSource()
    
    // MARK: - UseCases
    
    func makeGetProductsUseCase() -> GetProductsUseCase {
        GetProductsUseCase(productRepository: productRepository)
    }
    
    func makeSearchProductsUseCase() -> SearchProductsUseCase {
        SearchProductsUseCase(productRepository: productRepository)
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
    
    func makeAdminCatalogViewModel() -> AdminCatalogViewModel {
            AdminCatalogViewModel(
                getProductsUseCase:    makeGetProductsUseCase(),
                searchProductsUseCase: makeSearchProductsUseCase(),
                promotionDataSource:   promotionDataSource
            )
    }
    
    func makeProductFormViewModel(
        mode:    ProductFormMode,
        onSave:  @escaping (Product) -> Void
    ) -> ProductFormViewModel {
        ProductFormViewModel(
            mode:                 mode,
            createProductUseCase: CreateProductUseCase(productRepository: productRepository),
            updateProductUseCase: UpdateProductUseCase(productRepository: productRepository),
            deleteProductUseCase: DeleteProductUseCase(productRepository: productRepository),
            onSave:               onSave
        )
    }
    
    func makePromotionFormViewModel(
        mode:   PromotionFormMode,
        onSave: @escaping (Promotion) -> Void
    ) -> PromotionFormViewModel {
        PromotionFormViewModel(
            mode:                mode,
            promotionDataSource: promotionDataSource,
            productRepository:   productRepository,
            onSave:              onSave
        )
    }
}
