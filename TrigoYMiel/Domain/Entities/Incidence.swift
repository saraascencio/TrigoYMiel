//
//  Incidence.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - Incidence
// Representa un reporte de incidencia enviado por un cliente.
// Se mapea desde la colección "incidencias" de Firestore.
//
// El cliente la crea desde SupportView.
// El admin la gestiona desde IncidencesView y la resuelve en IncidenceDetailView.
//
// Campos de Firestore:
//   incidencia_id, tipo, canal, descripcion, evidencia_url,
//   fecha_creacion, estado, resolucion, fecha_resolucion,
//   admin_id, usuario_id, pedido_id

struct Incidence: Identifiable, Equatable {
    let id: String                  // incidencia_id
    let userId: String              // usuario_id → cliente que reportó
    let orderId: String             // pedido_id → pedido relacionado
    var adminId: String?            // admin_id → admin que resuelve (nil hasta que se asigna)
    let type: IncidenceType         // tipo
    let channel: ContactChannel     // canal → cómo quiere ser contactado el cliente
    let description: String         // descripcion libre del problema
    let evidenceURL: String?        // evidencia_url (foto adjunta, opcional)
    let createdAt: Date             // fecha_creacion
    var status: IncidenceStatus     // estado (mutable: el admin lo actualiza)
    var resolution: String?         // resolucion (nota del admin al resolver)
    var resolvedAt: Date?           // fecha_resolucion
    
    // MARK: - Computed helpers
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_SV")
        return formatter.string(from: createdAt)
    }
    
   
}

// MARK: - IncidenceStatus
enum IncidenceStatus: String, Codable {
    case open     = "abierta"
    case resolved = "resuelta"

    var displayName: String {
        switch self {
        case .open:     return "Abierta"
        case .resolved: return "Resuelta"
        }
    }
}
