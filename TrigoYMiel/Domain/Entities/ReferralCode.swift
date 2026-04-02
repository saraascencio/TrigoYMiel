//
//  ReferralCode.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - ReferralCode
// Representa un código de referido en el sistema.
// Se mapea desde la colección "referidos" de Firestore.
//
// Flujo del sistema de referidos:
//  1. El cliente A comparte su código desde WholesaleLockedView (InviteFriendUseCase).
//  2. El cliente B lo ingresa al registrarse en RegisterView.
//  3. RegisterUseCase llama a UnlockWholesaleUseCase.
//  4. UnlockWholesaleUseCase valida el código y:
//     - Activa mayoreo_activo = true en el usuario A (invitador).
//     - Crea el registro en la colección "referidos" con estado = true.
//     - La cuenta del cliente B se crea con tier .retail (el mayoreo es para A).
//
// Campos de Firestore:
//   referido_id, codigo, fechauso, estado,
//   invitador_id, invitado_id

struct ReferralCode: Identifiable, Equatable {
    let id: String              // referido_id
    let code: String            // codigo único del invitador
    let usedAt: Date?           // fechauso (nil si aún no ha sido usado)
    let isUsed: Bool            // estado → true si ya fue canjeado
    let inviterId: String       // invitador_id → usuario que generó el código
    let inviteeId: String?      // invitado_id → usuario que lo usó (nil si no se ha usado)
}
