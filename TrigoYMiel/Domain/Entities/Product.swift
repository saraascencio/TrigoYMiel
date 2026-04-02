//
//  Product.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - Product
// Representa un producto del catálogo de la panadería.
// Se mapea desde la colección "productos" de Firestore mediante ProductMapper.
//
// Campos de Firestore:
//   producto_id, nombre, descripcion, ingredientes,
//   precio_unitario, stock, disponible, categoria_id

struct Product: Identifiable, Equatable {
    let id: String              // producto_id
    let name: String            // nombre
    let description: String     // descripcion
    let ingredients: [String]   // ingredientes → array<string>
    let unitPrice: Double       // precio_unitario
    var stock: Int              // stock (mutable: el admin lo actualiza)
    let isAvailable: Bool       // disponible
    let categoryId: String      // categoria_id → Referencia a ProductCategory
    let imageURL: String        // imagen del producto (almacenada en Firebase Storage)
    let isPopular: Bool         // marca si aparece en la sección "Populares" del Catálogo

    // MARK: - Computed helpers

    /// Precio formateado para mostrar en la UI: "$3.50"
    var formattedPrice: String {
        String(format: "$%.2f", unitPrice)
    }

    /// true si hay stock disponible y el producto está marcado como disponible
    var isInStock: Bool {
        isAvailable && stock > 0
    }
}
