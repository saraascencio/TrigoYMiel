//
//  ProductRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - ProductRepository
// Protocolo que define las operaciones sobre productos del catálogo.
// La implementación concreta combina Firestore (fuente de verdad)
// con CoreData (caché local para modo offline).

protocol ProductRepository {
    
    /// Devuelve todos los productos activos del catálogo.
    /// Primero intenta desde Firestore; si no hay red, devuelve la caché de CoreData.
    func getAllProducts() async throws -> [Product]
    
    /// Devuelve los productos filtrados por categoría.
    func getProducts(byCategory categoryId: String) async throws -> [Product]
    
    /// Devuelve los productos marcados como populares (isPopular = true).
    /// Usados en la sección "Populares" de CatalogView.
    func getPopularProducts() async throws -> [Product]
    
    /// Búsqueda por nombre desde la barra de CatalogView.
    func searchProducts(query: String) async throws -> [Product]
    
    /// Devuelve un producto por su ID.
    /// Lanza: .productNotAvailable si no existe o está inactivo.
    func getProduct(id: String) async throws -> Product
    
    /// Crea un nuevo producto en Firestore. Solo para admin.
    /// Lanza: .unauthorized si el llamador no es admin.
    func createProduct(_ product: Product) async throws -> Product
    
    /// Actualiza un producto existente en Firestore. Solo para admin.
    /// Lanza: .unauthorized, .productNotAvailable
    func updateProduct(_ product: Product) async throws -> Product
    
    /// Soft delete: marca el producto como disponible = false en Firestore.
    /// No elimina el documento para preservar los _snap de pedidos históricos.
    /// Lanza: .unauthorized, .productNotAvailable
    func deleteProduct(id: String) async throws
    
    /// Devuelve todas las categorías activas.
    func getAllCategories() async throws -> [ProductCategory]
    
    func getActivePromotions() async throws -> [Promotion]
}
