//
//  AuthCoordinator.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI
import Combine
// MARK: - AuthCoordinator
// Navega entre Login y Register dentro del flujo de autenticación.

struct AuthCoordinator: View {

    @StateObject private var router = AuthRouter()

    let diContainer: AuthDIContainer
    let onAuthSuccess: (User) -> Void

    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(
                viewModel: diContainer.makeLoginViewModel(
                    onLoginSuccess: onAuthSuccess
                )
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterView(
                        viewModel: diContainer.makeRegisterViewModel(
                            onRegisterSuccess: onAuthSuccess
                        )
                    )
                }
            }
            
        }
        .environmentObject(router)
    }
}

// MARK: - AuthRouter

enum AuthRoute: Hashable {
    case register
}

final class AuthRouter: ObservableObject {
    @Published var path = NavigationPath()

    func goToRegister() { path.append(AuthRoute.register) }
    func goBack()       { if !path.isEmpty { path.removeLast() } }
}
