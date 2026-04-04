//
//  AuthFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

// AuthFirestoreDataSource
// Maneja Firebase Auth y el documento del usuario en la colección "usuarios".

final class AuthFirestoreDataSource {

    private let client = FirestoreClient.shared

    // MARK: - Login

    func login(email: String, password: String) async throws -> User {
        do {
            let result = try await client.auth.signIn(withEmail: email, password: password)
            return try await fetchUser(id: result.user.uid)
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    // MARK: - Register

    func register(
        name: String,
        phone: String,
        email: String,
        password: String
    ) async throws -> User {
        do {
            let result = try await client.auth.createUser(withEmail: email, password: password)
            let uid    = result.user.uid

            let newUser = User(
                id:              uid,
                name:            name,
                phone:           phone,
                email:           email,
                role:            .client,
                tier:            .retail,
                isActive:        true,
                registeredAt:    Date(),
                fcmToken:        nil,
                wholesaleActive: false
            )

            try await client.usersCollection
                .document(uid)
                .setData(UserMapper.toFirestore(newUser))

            return newUser
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    // MARK: - Logout

    func logout() throws {
        do {
            try client.auth.signOut()
        } catch {
            throw AppError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Current user

    func currentUser() async throws -> User? {
        guard let firebaseUser = client.auth.currentUser else { return nil }
        return try await fetchUser(id: firebaseUser.uid)
    }

    // MARK: - Helpers (usados por ReferralRepositoryImpl)

    func fetchUser(id: String) async throws -> User {
        do {
            let doc = try await client.usersCollection.document(id).getDocument()
            guard let data = doc.data() else { throw AppError.userNotFound }
            return try UserMapper.toDomain(from: data, id: id)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }

    func updateWholesaleActive(userId: String, active: Bool) async throws {
        do {
            try await client.usersCollection
                .document(userId)
                .updateData(["wholesaleActive": active])
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }

    // MARK: - Auth error mapping

    private func mapAuthError(_ error: NSError) -> AppError {
        switch AuthErrorCode(rawValue: error.code) {
        case .wrongPassword, .invalidEmail, .invalidCredential:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .userNotFound:
            return .userNotFound
        case .networkError:
            return .networkUnavailable
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
