//
//  ProductRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

// ProductRepositoryImpl
// Estrategia network-first con fallback a caché CoreData cuando no hay red.

final class ProductRepositoryImpl: ProductRepository {

    private let remoteDataSource = ProductFirestoreDataSource()
    private let localDataSource  = ProductCoreDataSource()

    // MARK: - Read

    func getAllProducts() async throws -> [Product] {
        do {
            let products = try await remoteDataSource.getAllProducts()
            try? localDataSource.saveProducts(products)   // actualiza caché en background
            return products
        } catch AppError.networkUnavailable {
            return try localDataSource.getAllProducts()
        } catch {
            if let cached = try? localDataSource.getAllProducts(), !cached.isEmpty {
                return cached
            }
            throw error
        }
    }

    func getProducts(byCategory categoryId: String) async throws -> [Product] {
        do {
            return try await remoteDataSource.getProducts(byCategory: categoryId)
        } catch {
            return (try? localDataSource.getAllProducts())?
                .filter { $0.categoryId == categoryId && $0.isAvailable } ?? []
        }
    }

    func getPopularProducts() async throws -> [Product] {
        do {
            return try await remoteDataSource.getPopularProducts()
        } catch {
            return (try? localDataSource.getAllProducts())?
                .filter { $0.isPopular && $0.isAvailable } ?? []
        }
    }

    func searchProducts(query: String) async throws -> [Product] {
        do {
            return try await remoteDataSource.searchProducts(query: query)
        } catch {
            return (try? localDataSource.getAllProducts())?
                .filter { $0.name.localizedCaseInsensitiveContains(query) } ?? []
        }
    }

    func getProduct(id: String) async throws -> Product {
        do {
            return try await remoteDataSource.getProduct(id: id)
        } catch {
            if let cached = try? localDataSource.getProduct(id: id) { return cached }
            throw AppError.productNotAvailable
        }
    }

    // MARK: - Write (Admin)

    func createProduct(_ product: Product) async throws -> Product {
        let created = try await remoteDataSource.createProduct(product)
        try? localDataSource.upsertProduct(created)
        return created
    }

    func updateProduct(_ product: Product) async throws -> Product {
        let updated = try await remoteDataSource.updateProduct(product)
        try? localDataSource.upsertProduct(updated)
        return updated
    }

    func deleteProduct(id: String) async throws {
        try await remoteDataSource.deleteProduct(id: id)
    }

    func getAllCategories() async throws -> [ProductCategory] {
        try await remoteDataSource.getAllCategories()
    }
}
