//
//  AuthRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation
import FirebaseAuth

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
        
        var user: User? = nil
        
        if let localUser = try? sessionDataSource.getActiveSession() {
            user = localUser
        } else {
            user = try await remoteDataSource.currentUser()
        }
        

        guard var currentUser = user else { return nil }
     
        if let firebaseAuthUser = Auth.auth().currentUser,
           let verifiedEmail = firebaseAuthUser.email {
            

            if verifiedEmail != currentUser.email {
                
        
                try await remoteDataSource.updateEmailInFirestore(userId: currentUser.id, newEmail: verifiedEmail)
                
            
                currentUser = User(
                    id:              currentUser.id,
                    name:            currentUser.name,
                    phone:           currentUser.phone,
                    email:           verifiedEmail,
                    role:            currentUser.role,
                    tier:            currentUser.tier,
                    isActive:        currentUser.isActive,
                    registeredAt:    currentUser.registeredAt,
                    fcmToken:        currentUser.fcmToken,
                    wholesaleActive: currentUser.wholesaleActive
                )
                
             
                try? sessionDataSource.saveSession(currentUser)
            }
        }
        
        return currentUser
    }
    
    
    func updateLocalSession(_ user: User) {
        try? sessionDataSource.saveSession(user)
    }
}

