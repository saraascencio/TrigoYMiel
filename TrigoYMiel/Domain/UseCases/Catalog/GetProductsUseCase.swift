//
//  GetProductsUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - GetProductsUseCase
// Devuelve todos los productos activos del catálogo.
//
// Usado por: CatalogViewModel (carga inicial de CatalogView)

final class GetProductsUseCase {

    private let productRepository: ProductRepository

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    func execute() async throws -> [Product] {
        try await productRepository.getAllProducts()
    }
}
