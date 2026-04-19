//
//  Promotion.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Promotion
// Representa una promoción del negocio.
// Se mapea desde la colección "promociones" de Firestore.
// Solo los usuarios con tier .wholesale pueden ver y aplicar las promociones
// marcadas como solo_mayoristas = true.
//
// Campos de Firestore:
//   promocion_id, descripcion, descuento_porcentaje,
//   solo_mayoristas, fecha_inicio, fecha_fin,
//   activa, productos_aplicables (array<reference>)

struct Promotion: Identifiable, Equatable, Codable {
    @DocumentID var id: String? // promocion_id
    let description: String                 // descripcion
    let discountPercentage: Double          // descuento_porcentaje (ej: 10.0 = 10%)
    let wholesaleOnly: Bool                 // solo_mayoristas
    let startDate: Date                    // fecha_inicio
    let endDate: Date                      // fecha_fin
    let isActive: Bool                      // activa
    let applicableProductIds: [String]      // productos_aplicables → array<reference>

    // MARK: - Computed helpers

    /// true si la promoción está activa y dentro del período vigente
    var isCurrentlyValid: Bool {
        guard isActive else { return false }
        let now = Date()
        return now >= startDate && now <= endDate
    }

    /// Descuento formateado: "10%"
    var formattedDiscount: String {
        "\(Int(discountPercentage))%"
    }
}
