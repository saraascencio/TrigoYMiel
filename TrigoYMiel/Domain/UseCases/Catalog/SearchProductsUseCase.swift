//
//  SearchProductsUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - SearchProductsUseCase
// Búsqueda de productos por nombre desde la barra de CatalogView.
// Devuelve lista vacía si el query está vacío, evitando llamadas innecesarias.
//
// Usado por: CatalogViewModel

final class SearchProductsUseCase {

    private let productRepository: ProductRepository

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    func execute(query: String) async throws -> [Product] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        return try await productRepository.searchProducts(query: trimmed)
    }
}
