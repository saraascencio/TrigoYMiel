//
//  ProductCoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import CoreData

// ProductCoreDataSource
// Caché local del catálogo en CoreData.
// Se alimenta cuando ProductRepositoryImpl descarga el catálogo de Firestore.
final class ProductCoreDataSource {

    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    // MARK: - Read

    func getAllProducts() throws -> [Product] {
        let request: NSFetchRequest<CDProductCache> = CDProductCache.fetchRequest()
        do {
            return try context.fetch(request).compactMap { try? ProductMapper.toDomain(from: $0) }
        } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }

    func getProduct(id: String) throws -> Product? {
        guard let entity = try? fetchCDProduct(id: id) else { return nil }
        return try? ProductMapper.toDomain(from: entity)
    }

    // MARK: - Write

    /// Reemplaza toda la caché con la lista descargada de Firestore.
    func saveProducts(_ products: [Product]) throws {
        try clearCache()
        products.forEach { product in
            let entity = CDProductCache(context: context)
            ProductMapper.toCache(product, entity: entity)
        }
        try saveContext()
    }

    /// Inserta o actualiza un producto individual en caché.
    func upsertProduct(_ product: Product) throws {
        let entity = (try? fetchCDProduct(id: product.id)) ?? CDProductCache(context: context)
        ProductMapper.toCache(product, entity: entity)
        try saveContext()
    }

    func clearCache() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = CDProductCache.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            let objectIDs = result?.result as? [NSManagedObjectID] ?? []

            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: objectIDs
            ]

            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [context]
            )

        } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }
    // MARK: - Private

    private func fetchCDProduct(id: String) throws -> CDProductCache? {
        let request: NSFetchRequest<CDProductCache> = CDProductCache.fetchRequest()
        request.predicate  = NSPredicate(format: "productId == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func saveContext() throws {
        guard context.hasChanges else { return }
        do { try context.save() } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }
}
