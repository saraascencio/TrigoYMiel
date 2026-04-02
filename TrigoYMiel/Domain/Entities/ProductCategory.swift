//
//  ProductCategory.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - ProductCategory
// Representa una categoría de producto.
// Se mapea desde la colección "categorias" de Firestore.
//
// Campos de Firestore:
//   categoria_id, nombre, descripcion, activa

struct ProductCategory: Identifiable, Equatable, Hashable {
    let id: String          // categoria_id
    let name: String        // nombre
    let description: String // descripcion
    let isActive: Bool      // activa
}

// MARK: - ProductCategoryType
// Enum de las categorías conocidas del catálogo.
// Usado en la UI para los filtros del Catálogo (CategoryFilterView).
// Si el negocio agrega nuevas categorías en Firestore, este enum
// no necesita actualizarse — la UI las muestra dinámicamente.

enum ProductCategoryType: String, CaseIterable {
    case tradicional = "Tradicional"
    case dulce       = "Dulce"
    case integral    = "Integral"
    case empacados   = "Empacados"
}
