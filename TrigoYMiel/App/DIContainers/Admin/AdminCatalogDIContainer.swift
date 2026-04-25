//
//  AdminCatalogDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 8/4/26.
//
import Foundation

final class AdminCatalogDIContainer {

    private let productRepository: ProductRepository = ProductRepositoryImpl()

    func makeAdminCatalogViewModel() -> AdminCatalogViewModel {
        AdminCatalogViewModel(
            getProductsUseCase:    GetProductsUseCase(productRepository: productRepository),
            searchProductsUseCase: SearchProductsUseCase(productRepository: productRepository)
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
}
