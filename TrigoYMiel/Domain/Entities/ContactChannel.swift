//
//  ContactChannel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - ContactChannel
// Canal preferido de contacto que el cliente elige en SupportView.
// Mapeado al campo "canal" en Firestore.
// La llamada telefónica solo está disponible de 10:00 am a 5:00 pm.

enum ContactChannel: String, Codable, CaseIterable {
    case chat  = "chat"
    case phone = "llamada"
    case email = "correo"

    var displayName: String {
        switch self {
        case .chat:  return "Chat"
        case .phone: return "Llamada"
        case .email: return "Correo"
        }
    }

    /// Nota informativa para mostrar junto a cada canal en la UI
    var note: String? {
        switch self {
        case .phone: return "10:00 am – 5:00 pm"
        default:     return nil
        }
    }
}
