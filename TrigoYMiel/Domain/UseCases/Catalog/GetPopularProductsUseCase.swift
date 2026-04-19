//
//  GetPopularProductsUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 15/4/26.
//
import Foundation

final class GetPopularProductsUseCase {

    private let productRepository: ProductRepository

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    func execute() async throws -> [Product] {
        try await productRepository.getPopularProducts()
    }
}
