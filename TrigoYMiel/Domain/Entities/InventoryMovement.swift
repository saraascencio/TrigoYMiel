//
//  InventoryMovement.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - InventoryMovement
// Registro de una entrada o salida de stock.
// Se mapea desde la colección "movimientos_inventario" de Firestore.
//
// Campos de Firestore:
//   movimiento_id, tipo, cantidad, stock_resultante,
//   nota, fecha, producto_id, admin_id
//
// El campo stock_resultante es el stock del producto DESPUÉS de este movimiento.
// Se guarda como snapshot para que el historial sea auditable incluso si
// el stock actual cambia después.

struct InventoryMovement: Identifiable, Equatable {
    let id: String              // movimiento_id
    let productId: String       // producto_id → referencia al producto
    let adminId: String         // admin_id → referencia al admin que registró el movimiento
    let type: MovementType      // tipo → .entry | .exit
    let quantity: Int           // cantidad
    let resultingStock: Int     // stock_resultante (stock después del movimiento)
    let note: String            // nota descriptiva del movimiento
    let date: Date              // fecha del movimiento

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_SV")
        return formatter.string(from: date)
    }
}

// MARK: - MovementType
// Tipo de movimiento de inventario.
//
//  .entry → el admin registra mercancía que llega (aumenta el stock)
//  .exit  → el admin registra merma o ajuste manual (reduce el stock)

enum MovementType: String, Codable, CaseIterable {
    case entry = "entrada"
    case exit  = "salida"

    var displayName: String {
        switch self {
        case .entry: return "Entrada"
        case .exit:  return "Salida"
        }
    }
}
