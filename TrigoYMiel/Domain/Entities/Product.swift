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

/*struct Product: Identifiable, Equatable, Hashable {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}*/

// MARK: - Product
// Representa un producto del catálogo de la panadería.
// Se mapea desde la colección "productos" de Firestore mediante ProductMapper.

// MARK: - Product
struct Product: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let ingredients: [String]
    let unitPrice: Double
    var stock: Int
    let isAvailable: Bool
    let categoryId: String
    let imageURL: String
    let isPopular: Bool
    
    // MARK: - Computed helpers
    
    var formattedPrice: String {
        String(format: "$%.2f", unitPrice)
    }
    
    var isInStock: Bool {
        isAvailable && stock > 0
    }
    
    // MARK: - Descuento Mayorista
    
    /// Retorna el porcentaje de descuento mayorista si existe una promoción activa para este producto.
    func wholesaleDiscount(using promotions: [Promotion]) -> Int? {
        let now = Date()
        
        guard let promo = promotions.first(where: { promo in
            promo.wholesaleOnly &&
            promo.isActive &&
            promo.applicableProductIds.contains(self.id) &&
            promo.startDate <= now &&
            promo.endDate >= now
        }) else {
            return nil
        }
        
        // Solución al error: conversión explícita
        return Int(promo.discountPercentage)
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
