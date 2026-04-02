//
//  User.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - User
// Entidad principal del dominio. Representa tanto a un cliente como a un administrador.
// Se mapea desde la colección "usuarios" de Firestore mediante UserMapper.
//
// Campos de Firestore:
//   usuario_id, nombre, telefono, email, rol, activo,
//   fecha_registro, token_fcm, ubicacion_ultima,
//   mayoreo_activo
//
// Nota: la contraseña es gestionada exclusivamente por Firebase Auth,
//       nunca se almacena ni se expone en esta entidad.

struct User: Identifiable, Equatable {
    let id: String              // usuario_id
    let name: String            // nombre
    let phone: String           // telefono
    let email: String           // email
    let role: UserRole          // rol → .client | .admin
    let tier: ClientTier        // derivado de rol + mayoreo_activo
    let isActive: Bool          // activo
    let registeredAt: Date      // fecha_registro
    let fcmToken: String?       // token_fcm (notificaciones push)
    let wholesaleActive: Bool   // mayoreo_activo

    // MARK: - Computed helpers

    /// true si el usuario puede acceder y usar la sección de Mayoreo
    var canAccessWholesale: Bool {
        role == .client && wholesaleActive
    }

    /// true si el usuario es administrador
    var isAdmin: Bool {
        role == .admin
    }
}
