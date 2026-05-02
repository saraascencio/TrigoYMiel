//
//  AuthRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

final class AuthRepositoryImpl: AuthRepository {
    
    private let remoteDataSource  = AuthFirestoreDataSource()
    private let sessionDataSource = UserSessionCoreDataSource()
    
    func login(email: String, password: String) async throws -> User {
        let user = try await remoteDataSource.login(email: email, password: password)
        try? sessionDataSource.saveSession(user)
        return user
    }
    
    func register(
        name: String,
        phone: String,
        email: String,
        password: String,
        referralCode: String?
    ) async throws -> User {
        let user = try await remoteDataSource.register(
            name: name, phone: phone, email: email, password: password
        )
        
        if let code = referralCode {
            _ = try? await ReferralRepositoryImpl().validateAndActivate(
                code: code, inviteeId: user.id
            )
        }
        
        try? sessionDataSource.saveSession(user)
        return user
    }
    
    func logout() async throws {
        try remoteDataSource.logout()
        try? sessionDataSource.clearSession()
    }
    
    func currentUser() async throws -> User? {
        if let localUser = try? sessionDataSource.getActiveSession() {
            return localUser
        }
        return try await remoteDataSource.currentUser()
    }
    
    func updateLocalSession(_ user: User) {
        try? sessionDataSource.saveSession(user)
    }
}
