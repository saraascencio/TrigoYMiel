//
//  DeleteProductUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - DeleteProductUseCase
// El admin desactiva un producto (soft delete: disponible = false en Firestore).
// El documento permanece en Firestore para preservar los _snap
// de pedidos históricos que referencian este producto.
//
// Usado por: AdminCatalogViewModel

final class DeleteProductUseCase {

    private let productRepository: ProductRepository

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    func execute(productId: String) async throws {
        try await productRepository.deleteProduct(id: productId)
    }
}
