//
//  Order.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - Order
// Representa un pedido completo en el sistema.
// Se mapea desde la colección "pedidos" de Firestore mediante OrderMapper.
//
// Campos de Firestore:
//   pedido_id, fecha_creacion, fecha_retiro, estado,
//   tipo_pedido, total, notas_adicionales, items (array<map>),
//   requiere_anticipacion, usuario_id

struct Order: Identifiable, Equatable {
    let id: String                      // pedido_id
    let userId: String                  // usuario_id → referencia al cliente
    let createdAt: Date                 // fecha_creacion
    let pickupDate: Date                // fecha_retiro → hora seleccionada en CartView
    var status: OrderStatus             // estado (mutable: el admin lo actualiza)
    let orderType: OrderType            // tipo_pedido → snapshot del tier al confirmar
    let total: Double                   // total acumulado del pedido
    let additionalNotes: String         // notas_adicionales
    let items: [OrderItem]              // items → array<map> embebido en Firestore
    let requiresAdvanceNotice: Bool     // requiere_anticipacion (true si total > 75 uds)

    // MARK: - Computed helpers

    /// Total formateado: "$11.80"
    var formattedTotal: String {
        String(format: "$%.2f", total)
    }

    /// ID formateado para mostrar en la UI: "#00002"
    var displayId: String {
        "#\(id.prefix(5).uppercased())"
    }

    /// Suma total de unidades del pedido (para calcular requiere_anticipacion)
    var totalUnits: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    /// Fecha de retiro formateada: "2:00 pm"
    var formattedPickupTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "es_SV")
        return formatter.string(from: pickupDate).lowercased()
    }
}
