//
//  UpdateProductUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - UpdateProductUseCase
// El admin edita un producto existente en el catálogo.
//
// Usado por: ProductFormViewModel (modo edición)

final class UpdateProductUseCase {

    private let productRepository: ProductRepository

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    func execute(_ product: Product) async throws -> Product {
        guard !product.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.unknown("El nombre del producto es obligatorio.")
        }
        guard product.unitPrice > 0 else {
            throw AppError.unknown("El precio debe ser mayor a cero.")
        }
        return try await productRepository.updateProduct(product)
    }
}
