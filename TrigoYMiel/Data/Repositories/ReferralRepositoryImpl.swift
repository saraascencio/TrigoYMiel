//
//  ReferralRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// MARK: - ReferralRepositoryImpl
// Gestiona la colección "referralCodes" en Firestore.
final class ReferralRepositoryImpl: ReferralRepository {
    
    private let client = FirestoreClient.shared
    private let authDataSource = AuthFirestoreDataSource()
    
    // MARK: - Validate & Activate
    func validateAndActivate(code: String, inviteeId: String) async throws -> ReferralCode {
        do {
            let snapshot = try await client.referralCodesCollection
                .whereField("code", isEqualTo: code)
                .limit(to: 1)
                .getDocuments()
            
            guard let doc = snapshot.documents.first else {
                throw AppError.invalidReferralCode
            }
            
            let data = doc.data()
            
            guard let isUsed = data["isUsed"] as? Bool, !isUsed else {
                throw AppError.referralCodeAlreadyUsed
            }
            
            guard let inviterId = data["inviterId"] as? String,
                  inviterId != inviteeId else {
                throw AppError.invalidReferralCode
            }
            
            let now = Date()
            
            // Marcar código como usado y actualizar información
            try await client.referralCodesCollection.document(doc.documentID).updateData([
                "isUsed": true,
                "usedAt": Timestamp(date: now),
                "inviteeId": inviteeId
            ])
            
            // Activar mayoreo para el invitador
            try await authDataSource.updateWholesaleActive(userId: inviterId, active: true)
            
            return ReferralCode(
                id: doc.documentID,
                code: data["code"] as? String ?? code,
                usedAt: now,
                isUsed: true,
                inviterId: inviterId,
                inviteeId: inviteeId
            )
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Get or Create referral code
    func getReferralCode(userId: String) async throws -> ReferralCode {
        do {
            // Busca código existente del usuario
            let snapshot = try await client.referralCodesCollection
                .whereField("inviterId", isEqualTo: userId)     
                .limit(to: 1)
                .getDocuments()
            
            if let doc = snapshot.documents.first {
                return mapToDomain(doc.data(), id: doc.documentID)
            }
            
            // Si no tiene, crear uno nuevo
            return try await createCode(for: userId)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Validate code only (RegisterView)
    func validateCode(_ code: String) async throws -> Bool {
        do {
            let snapshot = try await client.referralCodesCollection
                .whereField("code", isEqualTo: code)            
                .limit(to: 1)
                .getDocuments()
            
            guard let doc = snapshot.documents.first else {
                throw AppError.invalidReferralCode
            }
            
            let isUsed = doc.data()["isUsed"] as? Bool ?? false
            if isUsed {
                throw AppError.referralCodeAlreadyUsed
            }
            return true
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Private helpers
    private func createCode(for userId: String) async throws -> ReferralCode {
        let code = generateUniqueCode()
        let ref = client.referralCodesCollection.document()
        
        try await ref.setData([
            "code": code,
            "isUsed": false,
            "inviterId": userId
            // "usedAt" y "inviteeId" se dejan en null (no se incluyen)
        ])
        
        return ReferralCode(
            id: ref.documentID,
            code: code,
            usedAt: nil,
            isUsed: false,
            inviterId: userId,
            inviteeId: nil
        )
    }
    
    private func generateUniqueCode() -> String {
        let charset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // sin O, 0, I, 1 para evitar confusión
        return String((0..<8).map { _ in charset.randomElement()! })
    }
    
    private func mapToDomain(_ data: [String: Any], id: String) -> ReferralCode {
        ReferralCode(
            id: id,
            code: data["code"] as? String ?? "",
            usedAt: (data["usedAt"] as? Timestamp)?.dateValue(),
            isUsed: data["isUsed"] as? Bool ?? false,
            inviterId: data["inviterId"] as? String ?? "",
            inviteeId: data["inviteeId"] as? String
        )
    }
}
