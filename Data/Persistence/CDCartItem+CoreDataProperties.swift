//
//  CDCartItem+CoreDataProperties.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 4/4/26.
//
//

public import Foundation
public import CoreData


public typealias CDCartItemCoreDataPropertiesSet = NSSet

extension CDCartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCartItem> {
        return NSFetchRequest<CDCartItem>(entityName: "CDCartItem")
    }

    @NSManaged public var addedAt: Date?
    @NSManaged public var cartItemId: String?
    @NSManaged public var productCategoryId: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productId: String?
    @NSManaged public var productImageURL: String?
    @NSManaged public var productIngredients: String?
    @NSManaged public var productIsAvailable: Bool
    @NSManaged public var productIsPopular: Bool
    @NSManaged public var productName: String?
    @NSManaged public var productStock: Int32
    @NSManaged public var productUnitPrice: Double
    @NSManaged public var quantity: Int32
    @NSManaged public var userId: String?

}

extension CDCartItem : Identifiable {

}
