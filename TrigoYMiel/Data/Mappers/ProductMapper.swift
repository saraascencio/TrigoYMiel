//
//  ProductMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

struct ProductMapper {

    // MARK: Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> Product {

       
        guard let name = data["name"] as? String else {
            throw AppError.decodingError
        }

        let description = data["description"] as? String ?? ""
        let ingredients = data["ingredients"] as? [String] ?? []
        let unitPrice   = data["unitPrice"]   as? Double  ?? 0.0
        let isAvailable = data["isAvailable"] as? Bool    ?? true
        let categoryId  = data["categoryId"]  as? String  ?? ""
        let imageURL    = data["imageURL"]    as? String  ?? ""
        let isPopular   = data["isPopular"]   as? Bool    ?? false

      
        let stock: Int
        if let intVal   = data["stock"] as? Int   { stock = intVal }
        else if let int64Val = data["stock"] as? Int64 { stock = Int(int64Val) }
        else { stock = 0 }

        return Product(
            id:          id,
            name:        name,
            description: description,
            ingredients: ingredients,
            unitPrice:   unitPrice,
            stock:       stock,
            isAvailable: isAvailable,
            categoryId:  categoryId,
            imageURL:    imageURL,
            isPopular:   isPopular
        )
    }

    // MARK: Domain → Firestore
    static func toFirestore(_ product: Product) -> [String: Any] {
        [
            "name":        product.name,
            "description": product.description,
            "ingredients": product.ingredients,
            "unitPrice":   product.unitPrice,
            "stock":       product.stock,
            "isAvailable": product.isAvailable,
            "categoryId":  product.categoryId,
            "imageURL":    product.imageURL,
            "isPopular":   product.isPopular
        ]
    }

    // MARK: CDProductCache → Domain
    static func toDomain(from cache: CDProductCache) throws -> Product {
        guard
            let id          = cache.productId,
            let name        = cache.name
        else {
            throw AppError.coreDataError("Caché de producto inválida.")
        }

        let description      = cache.productDescription ?? ""
        let categoryId       = cache.categoryId         ?? ""
        let imageURL         = cache.imageURL           ?? ""
        let ingredientsCSV   = cache.ingredients        ?? ""

        let ingredientsArray = ingredientsCSV
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return Product(
            id:          id,
            name:        name,
            description: description,
            ingredients: ingredientsArray,
            unitPrice:   cache.unitPrice,
            stock:       Int(cache.stock),
            isAvailable: cache.isAvailable,
            categoryId:  categoryId,
            imageURL:    imageURL,
            isPopular:   cache.isPopular
        )
    }

    // MARK: Domain → CDProductCache
    static func toCache(_ product: Product, entity: CDProductCache) {
        entity.productId          = product.id
        entity.name               = product.name
        entity.productDescription = product.description
        entity.ingredients        = product.ingredients.joined(separator: ",")
        entity.unitPrice          = product.unitPrice
        entity.stock              = Int32(product.stock)
        entity.isAvailable        = product.isAvailable
        entity.categoryId         = product.categoryId
        entity.imageURL           = product.imageURL
        entity.isPopular          = product.isPopular
        entity.cachedAt           = Date()
    }
}
