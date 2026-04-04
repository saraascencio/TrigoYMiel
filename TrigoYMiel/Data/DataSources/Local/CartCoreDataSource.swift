//
//  CartCoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import CoreData

// MARK: - CartCoreDataSource
// Carrito offline-first: persiste completamente en CoreData.
// Almacena snapshot del producto para funcionar sin conexión.

final class CartCoreDataSource {

    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    // MARK: - Read

    func getCartItems(userId: String) throws -> [CartItem] {
        let request: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: true)]

        do {
            return try context.fetch(request).compactMap { cartItemToDomain($0) }
        } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }

    // MARK: - Write

    func addItem(_ item: CartItem, userId: String) throws {
        // Si ya existe el producto en el carrito, incrementamos cantidad
        if let existing = fetchCDCartItem(productId: item.product.id, userId: userId) {
            existing.quantity += Int32(item.quantity)
        } else {
            let entity = CDCartItem(context: context)
            fillEntity(entity, from: item, userId: userId)
        }
        try saveContext()
    }

    func updateItem(_ item: CartItem, userId: String) throws {
        guard let existing = fetchCDCartItem(productId: item.product.id, userId: userId) else { return }
        if item.quantity <= 0 {
            context.delete(existing)
        } else {
            existing.quantity = Int32(item.quantity)
        }
        try saveContext()
    }

    func removeItem(productId: String, userId: String) throws {
        guard let entity = fetchCDCartItem(productId: productId, userId: userId) else { return }
        context.delete(entity)
        try saveContext()
    }

    func clearCart(userId: String) throws {
        let request: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        do {
            try context.fetch(request).forEach { context.delete($0) }
            try saveContext()
        } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }

    // MARK: - Private helpers

    private func fetchCDCartItem(productId: String, userId: String) -> CDCartItem? {
        let request: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
        request.predicate = NSPredicate(
            format: "productId == %@ AND userId == %@", productId, userId
        )
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func fillEntity(_ entity: CDCartItem, from item: CartItem, userId: String) {
        entity.cartItemId         = item.id
        entity.userId             = userId
        entity.productId          = item.product.id
        entity.productName        = item.product.name
        entity.productDescription = item.product.description
        entity.productIngredients = item.product.ingredients.joined(separator: ",")
        entity.productUnitPrice   = item.product.unitPrice
        entity.productStock       = Int32(item.product.stock)
        entity.productIsAvailable = item.product.isAvailable
        entity.productCategoryId  = item.product.categoryId
        entity.productImageURL    = item.product.imageURL
        entity.productIsPopular   = item.product.isPopular
        entity.quantity           = Int32(item.quantity)
        entity.addedAt            = Date()
    }

    private func cartItemToDomain(_ entity: CDCartItem) -> CartItem? {
        guard
            let cartItemId  = entity.cartItemId,
            let productId   = entity.productId,
            let name        = entity.productName,
            let description = entity.productDescription,
            let ingCSV      = entity.productIngredients,
            let categoryId  = entity.productCategoryId,
            let imageURL    = entity.productImageURL
        else { return nil }

        let ingredients = ingCSV
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let product = Product(
            id:          productId,
            name:        name,
            description: description,
            ingredients: ingredients,
            unitPrice:   entity.productUnitPrice,
            stock:       Int(entity.productStock),
            isAvailable: entity.productIsAvailable,
            categoryId:  categoryId,
            imageURL:    imageURL,
            isPopular:   entity.productIsPopular
        )

        return CartItem(id: cartItemId, product: product, quantity: Int(entity.quantity))
    }

    private func saveContext() throws {
        guard context.hasChanges else { return }
        do { try context.save() } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }
}
