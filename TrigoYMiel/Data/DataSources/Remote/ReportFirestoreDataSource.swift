//
//  ReportFirestoreDataSource.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

// MARK: - ReportFirestoreDataSource
// Calcula el SalesReport en el cliente a partir de los pedidos entregados de Firestore.
final class ReportFirestoreDataSource {
    
    private let orderDataSource = OrderFirestoreDataSource()
    
    func getSalesReport(period: DateInterval) async throws -> SalesReport {
        // Obtenemos solo los pedidos entregados en el período
        let orders = try await orderDataSource.getDeliveredOrders(in: period)
        
        // Cálculos principales
        let totalRevenue = orders.reduce(0.0) { $0 + $1.total }
        let totalOrders = orders.count
        let totalUnitsSold = orders.flatMap { $0.items }.reduce(0) { $0 + $1.quantity }
        
        // Agrupamos ventas por producto para obtener el top de productos vendidos
        var salesMap: [String: (name: String, imageURL: String, units: Int, revenue: Double)] = [:]
        
        for order in orders {
            for item in order.items {
                if var entry = salesMap[item.productId] {
                    // Actualizar producto existente
                    entry.units += item.quantity
                    entry.revenue += item.subtotal
                    salesMap[item.productId] = entry
                } else {
                    // Nuevo producto
                    salesMap[item.productId] = (
                        name: item.nameSnap,
                        imageURL: item.imageURLSnap,
                        units: item.quantity,
                        revenue: item.subtotal
                    )
                }
            }
        }
        
        // Convertir el mapa a array de ProductSalesSummary y ordenar por unidades vendidas
        let topProducts = salesMap
            .map { id, value in
                ProductSalesSummary(
                    id: id,
                    productName: value.name,
                    imageURL: value.imageURL,
                    unitsSold: value.units,
                    revenue: value.revenue
                )
            }
            .sorted { $0.unitsSold > $1.unitsSold }   // Orden descendente por cantidad vendida
        
        return SalesReport(
            period: period,
            totalRevenue: totalRevenue,
            totalOrders: totalOrders,
            totalUnitsSold: totalUnitsSold,
            topProducts: topProducts
        )
    }
}
