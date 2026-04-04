//
//  AppCoordinator.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI
import Combine
import FirebaseAuth
// MARK: - AppCoordinator
// Lee el User post-login y bifurca a ClientTabCoordinator o AdminTabCoordinator.
// También maneja el estado de sesión al arrancar la app.

final class AppCoordinator: ObservableObject {

    @Published var currentUser: User?
    @Published var isLoading: Bool = true

    private let diContainer: AppDIContainer

    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
    }

    // MARK: - Session check al arrancar
    func checkExistingSession() async {
        //try? FirestoreClient.shared.auth.signOut()
        //descomentar para probar login y registro
        
        async let minimumDelay: () = Task.sleep(nanoseconds: 2_300_000_000)
        
        do {
            guard FirestoreClient.shared.auth.currentUser != nil else {
                try? await minimumDelay
                await MainActor.run {
                    self.currentUser = nil
                    self.isLoading   = false
                }
                return
            }

            let user = try await AuthRepositoryImpl().currentUser()
            try? await minimumDelay
            await MainActor.run {
                self.currentUser = user
                self.isLoading   = false
            }
        } catch {
            try? await minimumDelay
            await MainActor.run {
                self.currentUser = nil
                self.isLoading   = false
            }
        }
    }
    // MARK: - Callbacks

    func onLoginSuccess(_ user: User) {
        currentUser = user
    }

    func onLogout() {
        currentUser = nil
    }
}
