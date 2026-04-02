//
//  InventoryEntry.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - InventoryEntry
// Snapshot del stock actual de un producto.
// Usado en InventoryView para listar todos los productos con su stock.
// No es una colección de Firestore por sí sola — se construye
// combinando datos de "productos" y "movimientos_inventario".

struct InventoryEntry: Identifiable, Equatable {
    let id: String              // producto_id
    let productName: String     // nombre del producto
    let imageURL: String        // imagen del producto
    let categoryId: String      // categoria_id
    var currentStock: Int       // stock actual (campo "stock" en Firestore)
    let lastUpdated: Date       // fecha del último movimiento registrado
 
    // MARK: - Helpers
 
    /// true si el stock está en nivel bajo (≤ 5 unidades)
    var isLowStock: Bool {
        currentStock <= 5
    }
}
