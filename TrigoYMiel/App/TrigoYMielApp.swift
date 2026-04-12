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

struct AppRootView: View {

    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var diContainer:    AppDIContainer

    var body: some View {
        Group {
            if appCoordinator.isLoading {
                SplashView()
            } else if let user = appCoordinator.currentUser {
                if user.isAdmin {
                    AdminTabCoordinator(
                        diContainer: diContainer,
                        currentUser: user,
                        onLogout: {                          
                            Task { await appCoordinator.handleLogout() }
                        }
                    )
                } else {
                    Text("Client Tab — pendiente")
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
