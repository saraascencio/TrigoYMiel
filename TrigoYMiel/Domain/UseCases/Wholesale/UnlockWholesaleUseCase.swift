//
//  UnlockWholesaleUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

// MARK: - UnlockWholesaleUseCase
// Activa el acceso mayorista en el usuario invitador cuando
// alguien se registra usando su código de referido.
//
// Si el código es válido y no ha sido usado:
//   - Actualiza mayoreo_activo = true en el invitador (Firestore).
//   - Marca el código como usado.
//   - Registra el invitado_id en el documento del referido.
//
// Usado por: WholesaleViewModel

final class UnlockWholesaleUseCase {

    private let referralRepository: ReferralRepository

    init(referralRepository: ReferralRepository) {
        self.referralRepository = referralRepository
    }

    func execute(code: String, inviteeId: String) async throws -> ReferralCode {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw AppError.invalidReferralCode
        }
        return try await referralRepository.validateAndActivate(
            code: trimmed,
            inviteeId: inviteeId
        )
    }
}
