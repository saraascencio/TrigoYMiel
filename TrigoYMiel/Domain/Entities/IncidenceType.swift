//
//  IncidenceType.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - IncidenceType
// Tipo de incidencia que el cliente puede seleccionar en IncidenceTypePickerView.
// Mapeado al campo "tipo" en Firestore.

enum IncidenceType: String, Codable, CaseIterable {
    case incompleteOrder = "pedido_incompleto"
    case allergen        = "alergeno"
    case query           = "consulta"

    var displayName: String {
        switch self {
        case .incompleteOrder: return "Pedido incompleto"
        case .allergen:        return "Alérgeno"
        case .query:           return "Consulta"
        }
    }
}
