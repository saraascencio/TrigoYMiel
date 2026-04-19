//
//  OrderFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
/*import Foundation
import FirebaseFirestore

// MARK: - OrderFirestoreDataSource
// Maneja la colección "orders" en Firestore.
final class OrderFirestoreDataSource {
    
    private let client = FirestoreClient.shared
    
    // MARK: - Place Order
    func placeOrder(_ order: Order) async throws -> Order {
        do {
            try await client.ordersCollection
                .document(order.id)
                .setData(OrderMapper.toFirestore(order))
            return order
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Client queries
    func getActiveOrders(userId: String) async throws -> [Order] {
        let activeStatuses = OrderStatus.allCases
            .filter { $0.isActive }
            .map { $0.rawValue }
        
        let query = client.ordersCollection
            .whereField("userId", isEqualTo: userId)                    // ← corregido
            .whereField("status", in: activeStatuses)                   // ← corregido
        
        return try await fetchOrders(query: query)
    }
    
    func getOrderHistory(userId: String) async throws -> [Order] {
        let query = client.ordersCollection
            .whereField("userId", isEqualTo: userId)                    // ← corregido
            .whereField("status", isEqualTo: OrderStatus.delivered.rawValue) // ← corregido
        
        return try await fetchOrders(query: query)
    }
    
    func getOrderDetail(orderId: String) async throws -> Order {
        do {
            let doc = try await client.ordersCollection.document(orderId).getDocument()
            guard let data = doc.data() else {
                throw AppError.orderNotFound
            }
            return try OrderMapper.toDomain(from: data, id: orderId)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Admin queries
    func getAllOrders() async throws -> [Order] {
        try await fetchOrders(query: client.ordersCollection)
    }
    
    func updateOrderStatus(orderId: String, newStatus: OrderStatus) async throws -> Order {
        do {
            try await client.ordersCollection
                .document(orderId)
                .updateData(["status": newStatus.rawValue])             // ← corregido
            return try await getOrderDetail(orderId: orderId)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Report helper
    func getDeliveredOrders(in period: DateInterval) async throws -> [Order] {
        let query = client.ordersCollection
            .whereField("status", isEqualTo: OrderStatus.delivered.rawValue)   // ← corregido
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: period.start))   // ← corregido
            .whereField("createdAt", isLessThanOrEqualTo: Timestamp(date: period.end))        // ← corregido
        
        return try await fetchOrders(query: query)
    }
    
    // MARK: - Private
    private func fetchOrders(query: Query) async throws -> [Order] {
        do {
            let snapshot = try await query.getDocuments()
            return try snapshot.documents.map { doc in
                try OrderMapper.toDomain(from: doc.data(), id: doc.documentID)
            }
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
}*/
import Foundation
import FirebaseFirestore

// MARK: - OrderFirestoreDataSource
// Maneja la colección "orders" en Firestore.
final class OrderFirestoreDataSource {
    
    private let client = FirestoreClient.shared
    
    // MARK: - Place Order
    func placeOrder(_ order: Order) async throws -> Order {
        do {
            try await client.ordersCollection
                .document(order.id)
                .setData(OrderMapper.toFirestore(order))
            return order
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Client queries
    func getActiveOrders(userId: String) async throws -> [Order] {
        let activeStatuses = OrderStatus.allCases
            .filter { $0.isActive }
            .map { $0.rawValue }
        
        let query = client.ordersCollection
            .whereField("userId", isEqualTo: userId)
            .whereField("status", in: activeStatuses)
        
        return try await fetchOrders(query: query)
    }
    
    func getOrderHistory(userId: String) async throws -> [Order] {
        let query = client.ordersCollection
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: OrderStatus.delivered.rawValue)
        
        return try await fetchOrders(query: query)
    }
    
    // NUEVO: Método para validar el límite de 3 pedidos diarios
    func getOrderCountToday(userId: String) async throws -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        do {
            // Usamos la agregación .count para no consumir lecturas innecesarias
            let query = client.ordersCollection
                .whereField("userId", isEqualTo: userId)
                .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            
            let snapshot = try await query.count.getAggregation(source: .server)
            return Int(truncating: snapshot.count)
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    func getOrderDetail(orderId: String) async throws -> Order {
        do {
            let doc = try await client.ordersCollection.document(orderId).getDocument()
            guard let data = doc.data() else {
                throw AppError.orderNotFound
            }
            return try OrderMapper.toDomain(from: data, id: orderId)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Admin queries
    func getAllOrders() async throws -> [Order] {
        try await fetchOrders(query: client.ordersCollection)
    }
    
    func updateOrderStatus(orderId: String, newStatus: OrderStatus) async throws -> Order {
        do {
            try await client.ordersCollection
                .document(orderId)
                .updateData(["status": newStatus.rawValue])
            return try await getOrderDetail(orderId: orderId)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
    
    // MARK: - Report helper
    func getDeliveredOrders(in period: DateInterval) async throws -> [Order] {
        let query = client.ordersCollection
            .whereField("status", isEqualTo: OrderStatus.delivered.rawValue)
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: period.start))
            .whereField("createdAt", isLessThanOrEqualTo: Timestamp(date: period.end))
        
        return try await fetchOrders(query: query)
    }
    
    // MARK: - Private
    private func fetchOrders(query: Query) async throws -> [Order] {
        do {
            let snapshot = try await query.getDocuments()
            return try snapshot.documents.map { doc in
                try OrderMapper.toDomain(from: doc.data(), id: doc.documentID)
            }
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
}
