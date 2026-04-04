//
//  CDUserSession+CoreDataProperties.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 4/4/26.
//
//

public import Foundation
public import CoreData


public typealias CDUserSessionCoreDataPropertiesSet = NSSet

extension CDUserSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUserSession> {
        return NSFetchRequest<CDUserSession>(entityName: "CDUserSession")
    }

    @NSManaged public var email: String?
    @NSManaged public var fcmToken: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var registeredAt: Date?
    @NSManaged public var roleRaw: String?
    @NSManaged public var userId: String?
    @NSManaged public var wholesaleActive: Bool

}

extension CDUserSession : Identifiable {

}
