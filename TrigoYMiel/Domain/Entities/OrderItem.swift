//
//  OrderItem.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - OrderItem
// Representa un artículo dentro de un pedido confirmado.
// Se almacena como array<map> embebido dentro del documento Pedido en Firestore.
//
// Los campos _snap (snapshot) son críticos:
// capturan el estado del producto EN EL MOMENTO en que se confirmó el pedido.
// Esto garantiza que el historial de pedidos nunca se vea afectado si el admin
// cambia el nombre, precio o imagen de un producto después.
//
// Campos de Firestore (dentro del array "items" del pedido):
//   producto_id, nombre_snap, precio_unitario_snap,
//   imagen_url_snap, cantidad, subtotal

struct OrderItem: Identifiable, Equatable {
    let id: String              // UUID local para Identifiable en SwiftUI
    let productId: String       // producto_id → referencia al producto original
    let nameSnap: String        // nombre_snap → nombre al momento del pedido
    let unitPriceSnap: Double   // precio_unitario_snap → precio al momento del pedido
    let imageURLSnap: String    // imagen_url_snap → imagen al momento del pedido
    let quantity: Int           // cantidad
    let subtotal: Double        // subtotal (cantidad × precio_unitario_snap)

    // MARK: - Computed helpers

    var formattedUnitPrice: String {
        String(format: "$%.2f", unitPriceSnap)
    }

    var formattedSubtotal: String {
        String(format: "$%.2f", subtotal)
    }
}
