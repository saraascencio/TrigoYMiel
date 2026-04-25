//
//  FirestoreClient.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

// FirestoreCollections
// Centraliza nombres para evitar errores de strings

enum FirestoreCollections {
    static let user = "User"
    static let product = "Product"
    static let category = "ProductCategory"
    static let order = "Order"
    static let incidence = "Incidence"
    static let inventoryMovement = "InventoryMovement"
    static let promotion = "Promotion"
    static let referralCode = "ReferralCode"
}

// FirestoreClient
// Wrapper centralizado de Firebase. Provee acceso a Firestore, Auth y Storage.
// Singleton compartido por todos los DataSources remotos.

final class FirestoreClient {

    static let shared = FirestoreClient()

    let db: Firestore
    let storage: Storage
    let auth: Auth

    private init() {
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
        self.auth = Auth.auth()
    }

    // MARK: - Collection References

    var usersCollection: CollectionReference {
        db.collection(FirestoreCollections.user)
    }

    var productsCollection: CollectionReference {
        db.collection(FirestoreCollections.product)
    }

    var categoriesCollection: CollectionReference {
        db.collection(FirestoreCollections.category)
    }

    var ordersCollection: CollectionReference {
        db.collection(FirestoreCollections.order)
    }

    var incidencesCollection: CollectionReference {
        db.collection(FirestoreCollections.incidence)
    }

    var inventoryMovementsCollection: CollectionReference {
        db.collection(FirestoreCollections.inventoryMovement)
    }

    var promotionsCollection: CollectionReference {
        db.collection(FirestoreCollections.promotion)
    }

    var referralCodesCollection: CollectionReference {
        db.collection(FirestoreCollections.referralCode)
    }
}
