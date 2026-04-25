//
//  UserMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

struct UserMapper {

    // MARK: Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> User {

        // Solo email y registeredAt son críticos
        guard
            let email = data["email"]        as? String,
            let regTS = data["registeredAt"] as? Timestamp
        else {
            throw AppError.decodingError
        }

        let name     = data["name"]  as? String ?? "Usuario"
        let roleRaw  = data["role"]  as? String ?? UserRole.client.rawValue
        let role     = UserRole(rawValue: roleRaw) ?? .client
        let isActive = data["isActive"] as? Bool ?? true
        let phone    = data["phone"]    as? String ?? ""
        let wholesale = data["wholesaleActive"] as? Bool ?? false
        let tier: ClientTier = wholesale ? .wholesale : .retail

        return User(
            id:              id,
            name:            name,
            phone:           phone,
            email:           email,
            role:            role,
            tier:            tier,
            isActive:        isActive,
            registeredAt:    regTS.dateValue(),
            fcmToken:        data["fcmToken"] as? String,
            wholesaleActive: wholesale
        )
    }

    // MARK: Domain → Firestore
    static func toFirestore(_ user: User) -> [String: Any] {
        var data: [String: Any] = [
            "name":            user.name,
            "phone":           user.phone,
            "email":           user.email,
            "role":            user.role.rawValue,
            "isActive":        user.isActive,
            "registeredAt":    Timestamp(date: user.registeredAt),
            "wholesaleActive": user.wholesaleActive
        ]
        if let token = user.fcmToken {
            data["fcmToken"] = token
        }
        return data
    }
}
