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
    case cancelled      = "cancelado" // <--- Nuevo estado

    /// Texto legible para mostrar al cliente
    var displayName: String {
        switch self {
        case .pending:        return "Pendiente"
        case .inPreparation:  return "En preparación"
        case .readyForPickup: return "Listo para recoger"
        case .delivered:      return "Entregado"
        case .cancelled:      return "Cancelado"
        }
    }

    /// true si el pedido ya terminó su ciclo y va al historial
    var isCompleted: Bool {
        // Un pedido cancelado también se considera finalizado
        self == .delivered || self == .cancelled
    }

    /// true si el pedido aún está activo (visible en "Pedidos en curso")
    var isActive: Bool {
        !isCompleted
    }
    
    /// Define si el estado actual permite una cancelación
        /// (Por ejemplo: no tiene sentido cancelar algo que ya se entregó o ya se canceló)
        var canBeCancelled: Bool {
            switch self {
            case .pending, .inPreparation:
                return true
            case .readyForPickup, .delivered, .cancelled:
                return false
            }
        }
}

extension OrderStatus {
    var next: OrderStatus? {
        switch self {
        case .pending:        return .inPreparation
        case .inPreparation:  return .readyForPickup
        case .readyForPickup: return .delivered
        case .delivered:      return nil
        case .cancelled:      return nil 
        }
    }
}
