//
//  OrderStatus.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - OrderStatus
// Estado del ciclo de vida de un pedido.
// El admin cambia el estado desde AdminOrderDetailView.
// El cliente ve el estado en tiempo real desde ActiveOrdersView.
//
// Flujo normal:
//   .pending → .inPreparation → .readyForPickup → .delivered
//
// "Listo para recoger" se resalta de forma prominente en la UI del cliente
// (OrderStatusBadgeView) para que lo identifique de inmediato.

enum OrderStatus: String, Codable, CaseIterable {
    case pending        = "pendiente"
    case inPreparation  = "en_preparacion"
    case readyForPickup = "listo_para_recoger"
    case delivered      = "entregado"

    /// Texto legible para mostrar al cliente
    var displayName: String {
        switch self {
        case .pending:        return "Pendiente"
        case .inPreparation:  return "En preparación"
        case .readyForPickup: return "Listo para recoger"
        case .delivered:      return "Entregado"
        }
    }

    /// true si el pedido ya terminó su ciclo y va al historial
    var isCompleted: Bool {
        self == .delivered
    }

    /// true si el pedido aún está activo (visible en "Pedidos en curso")
    var isActive: Bool {
        !isCompleted
    }
}
