//
//  AuthDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

// MARK: - AuthDIContainer
// Ensambla las dependencias del flujo Auth.
// Crea el repositorio concreto y los UseCases que lo necesitan.

final class AuthDIContainer {

    // MARK: - Repository (una sola instancia compartida)
    private let authRepository: AuthRepository = AuthRepositoryImpl()

    // MARK: - UseCases

    func makeLoginUseCase() -> LoginUseCase {
        LoginUseCase(authRepository: authRepository)
    }

    func makeRegisterUseCase() -> RegisterUseCase {
        RegisterUseCase(authRepository: authRepository)
    }

    func makeLogoutUseCase() -> LogoutUseCase {
        LogoutUseCase(authRepository: authRepository)
    }

    // MARK: - ViewModels

    func makeLoginViewModel(onLoginSuccess: @escaping (User) -> Void) -> LoginViewModel {
        LoginViewModel(
            loginUseCase: makeLoginUseCase(),
            onLoginSuccess: onLoginSuccess
        )
    }

    func makeRegisterViewModel(onRegisterSuccess: @escaping (User) -> Void) -> RegisterViewModel {
        RegisterViewModel(
            registerUseCase: makeRegisterUseCase(),
            onRegisterSuccess: onRegisterSuccess
        )
    }
}
