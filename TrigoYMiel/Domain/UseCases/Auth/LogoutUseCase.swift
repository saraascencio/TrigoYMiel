//
//  LogoutUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - LogoutUseCase
// Cierra la sesión activa y limpia el estado local.
// El AppCoordinator escucha el resultado y navega de vuelta a AuthCoordinator.
//
// Usado por: CatalogViewModel (ícono de perfil en la barra superior de CatalogView)

final class LogoutUseCase {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() async throws {
        try await authRepository.logout()
    }
}
