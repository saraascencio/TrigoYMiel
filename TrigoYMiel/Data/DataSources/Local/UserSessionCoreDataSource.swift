//
//  UserSessionCoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import CoreData

// UserSessionCoreDataSource
// Persiste la sesión activa en CoreData para recuperar el usuario
// al relanzar la app sin llamar a Firestore.

final class UserSessionCoreDataSource {

    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    // MARK: - Read

    func getActiveSession() throws -> User? {
        let request: NSFetchRequest<CDUserSession> = CDUserSession.fetchRequest()
        request.fetchLimit = 1
        do {
            guard let entity = try context.fetch(request).first else { return nil }
            return try sessionToDomain(entity)
        } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }

    // MARK: - Write

    func saveSession(_ user: User) throws {
        try clearSession()
        let entity = CDUserSession(context: context)
        entity.userId          = user.id
        entity.name            = user.name
        entity.phone           = user.phone
        entity.email           = user.email
        entity.roleRaw         = user.role.rawValue
        entity.wholesaleActive = user.wholesaleActive
        entity.isActive        = user.isActive
        entity.registeredAt    = user.registeredAt
        entity.fcmToken        = user.fcmToken
        try saveContext()
    }

    func clearSession() throws {
        let request: NSFetchRequest<CDUserSession> = CDUserSession.fetchRequest()
        do {
            let results = try context.fetch(request)
            results.forEach { context.delete($0) }
            if context.hasChanges {
                try context.save()
            }
        } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }
    // MARK: - Private

    private func sessionToDomain(_ entity: CDUserSession) throws -> User {
        guard
            let userId  = entity.userId,
            let name    = entity.name,
            let phone   = entity.phone,
            let email   = entity.email,
            let roleRaw = entity.roleRaw,
            let role    = UserRole(rawValue: roleRaw),
            let regDate = entity.registeredAt
        else {
            throw AppError.coreDataError("Sesión local inválida.")
        }

        let tier: ClientTier = entity.wholesaleActive ? .wholesale : .retail

        return User(
            id:              userId,
            name:            name,
            phone:           phone,
            email:           email,
            role:            role,
            tier:            tier,
            isActive:        entity.isActive,
            registeredAt:    regDate,
            fcmToken:        entity.fcmToken,
            wholesaleActive: entity.wholesaleActive
        )
    }

    private func saveContext() throws {
        guard context.hasChanges else { return }
        do { try context.save() } catch {
            throw AppError.coreDataError(error.localizedDescription)
        }
    }
}
