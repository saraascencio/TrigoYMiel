//
//  ProductFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

final class ProductFirestoreDataSource {
    
    private let client = FirestoreClient.shared
    
    // MARK: - Fetch
    
    func getAllProducts() async throws -> [Product] {
        try await fetchProducts(query: client.productsCollection)
    }
    
    func getProducts(byCategory categoryId: String) async throws -> [Product] {
        let query = client.productsCollection
            .whereField("categoryId", isEqualTo: categoryId)
            .whereField("isAvailable", isEqualTo: true)
        return try await fetchProducts(query: query)
    }
    
    func getPopularProducts() async throws -> [Product] {
        let query = client.productsCollection
            .whereField("isPopular", isEqualTo: true)
            .whereField("isAvailable", isEqualTo: true)
        return try await fetchProducts(query: query)
    }
    
    func getProduct(id: String) async throws -> Product {
        do {
            let doc = try await client.productsCollection.document(id).getDocument()
            guard let data = doc.data() else { throw AppError.productNotAvailable }
            return try ProductMapper.toDomain(from: data, id: id)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        let end = query + "\u{f8ff}"
        let q = client.productsCollection
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThanOrEqualTo: end)
        return try await fetchProducts(query: q)
    }
    
    // MARK: - Write (Admin)
    
    func createProduct(_ product: Product) async throws -> Product {
        do {
            let ref = client.productsCollection.document()
            try await ref.setData(ProductMapper.toFirestore(product))
            
            return Product(
                id:          ref.documentID,
                name:        product.name,
                description: product.description,
                ingredients: product.ingredients,
                unitPrice:   product.unitPrice,
                stock:       product.stock,
                isAvailable: product.isAvailable,
                categoryId:  product.categoryId,
                imageURL:    product.imageURL,
                isPopular:   product.isPopular
            )
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    func updateProduct(_ product: Product) async throws -> Product {
        do {
            try await client.productsCollection
                .document(product.id)
                .setData(ProductMapper.toFirestore(product), merge: true)
            return product
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    func deleteProduct(id: String) async throws {
        do {
            try await client.productsCollection
                .document(id)
                .updateData(["isAvailable": false])
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Categories
    
    func getAllCategories() async throws -> [ProductCategory] {
        do {
            let snapshot = try await client.categoriesCollection
                .whereField("isActive", isEqualTo: true)
                .getDocuments()
            
            return try snapshot.documents.map { doc in
                let data = doc.data()
                guard
                    let name        = data["name"]        as? String,
                    let description = data["description"] as? String,
                    let isActive    = data["isActive"]    as? Bool
                else { throw AppError.decodingError }
                
                return ProductCategory(
                    id:          doc.documentID,
                    name:        name,
                    description: description,
                    isActive:    isActive
                )
            }
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func fetchProducts(query: Query) async throws -> [Product] {
        do {
            let snapshot = try await query.getDocuments()
            return try snapshot.documents.map { doc in
                try ProductMapper.toDomain(from: doc.data(), id: doc.documentID)
            }
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    func getActivePromotions() async throws -> [Promotion] {
        let snapshot = try await client.promotionsCollection
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Promotion.self)
        }
    }
}
