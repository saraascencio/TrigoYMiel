//
//  CDProductCache+CoreDataProperties.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 4/4/26.
//
//

public import Foundation
public import CoreData


public typealias CDProductCacheCoreDataPropertiesSet = NSSet

extension CDProductCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProductCache> {
        return NSFetchRequest<CDProductCache>(entityName: "CDProductCache")
    }

    @NSManaged public var cachedAt: Date?
    @NSManaged public var categoryId: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var isAvailable: Bool
    @NSManaged public var isPopular: Bool
    @NSManaged public var name: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productId: String?
    @NSManaged public var stock: Int32
    @NSManaged public var unitPrice: Double

}

extension CDProductCache : Identifiable {

}
