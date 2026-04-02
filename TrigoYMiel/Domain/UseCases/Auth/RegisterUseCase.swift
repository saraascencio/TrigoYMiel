//
//  RegisterUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - RegisterUseCase
// Crea una cuenta nueva.
// Si se proporciona un código de referido válido,
// activa el acceso mayorista en el usuario invitador.
//
// Usado por: RegisterViewModel

import Foundation

final class RegisterUseCase {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(
        name: String,
        phone: String,
        email: String,
        password: String,
        confirmPassword: String,
        referralCode: String?
    ) async throws -> User {

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.unknown("El nombre es obligatorio.")
        }
        guard !phone.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.unknown("El teléfono es obligatorio.")
        }
        guard password == confirmPassword else {
            throw AppError.unknown("Las contraseñas no coinciden.")
        }
        guard password.count >= 6 else {
            throw AppError.weakPassword
        }

        // Nil si el campo estaba vacío, valor limpio si tenía contenido
        let code = referralCode?.trimmingCharacters(in: .whitespaces)
        let codeToSend = (code?.isEmpty == false) ? code : nil

        return try await authRepository.register(
            name: name,
            phone: phone,
            email: email,
            password: password,
            referralCode: codeToSend
        )
    }
}
