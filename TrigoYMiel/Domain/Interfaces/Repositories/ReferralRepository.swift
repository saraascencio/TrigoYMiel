//
//  ReferralRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - ReferralRepository
// Protocolo para el sistema de referidos en Firestore.
// Usado por UnlockWholesaleUseCase e InviteFriendUseCase.

protocol ReferralRepository {

    /// Valida el código y activa el mayoreo del invitador.
    /// Si el código es válido y no ha sido usado:
    ///   - Actualiza mayoreo_activo = true en el invitador.
    ///   - Marca el código como usado (estado = true).
    ///   - Registra el invitado_id en el documento del referido.
    /// Lanza: .invalidReferralCode, .referralCodeAlreadyUsed
    func validateAndActivate(code: String, inviteeId: String) async throws -> ReferralCode

    /// Obtiene (o genera) el código de referido personal del usuario.
    /// Si no tiene uno, lo crea y lo guarda en Firestore.
    func getReferralCode(userId: String) async throws -> ReferralCode

    /// Verifica si un código existe y está disponible (no usado).
    /// Usado en RegisterView para validar en tiempo real.
    /// Lanza: .invalidReferralCode, .referralCodeAlreadyUsed
    func validateCode(_ code: String) async throws -> Bool
}
