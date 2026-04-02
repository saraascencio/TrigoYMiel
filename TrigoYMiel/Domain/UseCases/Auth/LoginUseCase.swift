//
//  LoginUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - LoginUseCase
// Autentica al usuario y devuelve su perfil completo.
// El AppCoordinator lee el UserRole del resultado para decidir
// qué TabCoordinator mostrar (cliente o admin).
//
// Usado por: LoginViewModel

import Foundation

final class LoginUseCase {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> User {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            throw AppError.invalidCredentials
        }

        return try await authRepository.login(email: trimmedEmail, password: password)
    }
}
