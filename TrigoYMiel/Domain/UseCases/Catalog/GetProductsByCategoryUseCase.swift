//
//  GetProductsByCategoryUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetProductsByCategoryUseCase
// Devuelve los productos filtrados por categoría.
//
// Usado por: CatalogViewModel (filtro en CategoryFilterView)

final class GetProductsByCategoryUseCase {

    private let productRepository: ProductRepository

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    func execute(categoryId: String) async throws -> [Product] {
        try await productRepository.getProducts(byCategory: categoryId)
    }
}
