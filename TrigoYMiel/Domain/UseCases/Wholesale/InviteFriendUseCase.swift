//
//  InviteFriendUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - InviteFriendUseCase
// Obtiene (o genera) el código de referido personal del usuario
// para compartirlo desde WholesaleLockedView.
//
// Si el usuario ya tiene un código en Firestore, lo devuelve.
// Si no tiene, el repositorio lo genera y lo guarda.
//
// Usado por: WholesaleViewModel (botón "Invitar a un amigo")

final class InviteFriendUseCase {

    private let referralRepository: ReferralRepository

    init(referralRepository: ReferralRepository) {
        self.referralRepository = referralRepository
    }

    func execute(userId: String) async throws -> ReferralCode {
        try await referralRepository.getReferralCode(userId: userId)
    }
}
