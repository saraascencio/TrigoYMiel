//
//  ClientTier.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - ClientTier
// Solo aplica cuando UserRole == .client.
// Controla los límites del carrito y la visibilidad de la sección Mayoreo.
//
//  .retail    → máx 15 unidades/tipo  |  máx 5 tipos por pedido
//  .wholesale → máx 100 unidades/tipo |  máx 10 tipos por pedido

/*enum ClientTier: String, Codable {
    case retail    = "minorista"
    case wholesale = "mayorista"

    // Límites de carrito según el tier activo
    var maxUnitsPerProductType: Int {
        switch self {
        case .retail:    return 15
        case .wholesale: return 100
        }
    }

    var maxProductTypes: Int {
        switch self {
        case .retail:    return 5
        case .wholesale: return 10
        }
    }
}*/
import Foundation

enum ClientTier: String, Codable {
    case retail    = "minorista"
    case wholesale = "mayorista"

    // 1. Máximo de unidades por cada tipo de producto (ej. max 15 conchas)
    var maxUnitsPerProductType: Int {
        switch self {
        case .retail:    return 15
        case .wholesale: return 100
        }
    }

    // 2. Máximo de tipos de productos distintos en el carrito (ej. max 5 tipos de pan)
    var maxProductTypes: Int {
        switch self {
        case .retail:    return 5
        case .wholesale: return 10
        }
    }
    
    // 3. NUEVO: Límite total de unidades sumando todo el carrito (ej. total 75 piezas)
    var maxTotalUnits: Int {
        switch self {
        case .retail:    return 75
        case .wholesale: return 1000
        }
    }
}
