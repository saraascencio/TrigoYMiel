//
//  OrderType.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - OrderType
// Indica si el pedido fue realizado bajo las reglas de minorista o mayorista.
// Se determina en el momento de confirmar el pedido según el ClientTier del usuario.
// Se guarda como snapshot en el pedido: aunque el usuario cambie de tier después,
// el tipo del pedido histórico no cambia.

enum OrderType: String, Codable {
    case retail    = "minorista"
    case wholesale = "mayorista"
 
    var displayName: String {
        switch self {
        case .retail:    return "Minorista"
        case .wholesale: return "Mayorista"
        }
    }
}
