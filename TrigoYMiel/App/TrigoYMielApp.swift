//
//  TrigoYMielApp.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI
import FirebaseCore

@main
struct TrigoYMielApp: App {

    @StateObject private var diContainer   = AppDIContainer()
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        FirebaseApp.configure()
        // AppCoordinator necesita el container, lo creamos antes del @StateObject
        let container = AppDIContainer()
        _appCoordinator = StateObject(
            wrappedValue: AppCoordinator(diContainer: container)
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(diContainer)
                .environmentObject(appCoordinator)
                .task { await appCoordinator.checkExistingSession() }
        }
    }
}

// MARK: - AppRootView
// Punto de decisión: ¿hay sesión activa? → bifurca a Auth o a la app.

struct AppRootView: View {

    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var diContainer:    AppDIContainer

    var body: some View {
        Group {
            if appCoordinator.isLoading {
                SplashView()
            } else if let user = appCoordinator.currentUser {
                // Bifurca según rol
                if user.isAdmin {
                    Text("Admin Tab — pendiente") // AdminTabCoordinator irá aquí
                } else {
                    Text("Client Tab — pendiente") // ClientTabCoordinator irá aquí
                }
            } else {
                AuthCoordinator(
                    diContainer: diContainer.authDIContainer,
                    onAuthSuccess: { user in
                        appCoordinator.onLoginSuccess(user)
                    }
                )
            }
        }
    }
}

