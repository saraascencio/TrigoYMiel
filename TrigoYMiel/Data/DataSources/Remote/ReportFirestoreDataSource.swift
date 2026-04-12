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
        
        // Obtener pedidos entregados en el período
        let orders = try await orderDataSource.getDeliveredOrders(in: period)
        
        // Totales generales
        let totalRevenue = orders.reduce(0.0) { $0 + $1.total }
        let totalOrders = orders.count
        let totalUnitsSold = orders.flatMap { $0.items }.reduce(0) { $0 + $1.quantity }
        
        // TOP productos
        var salesMap: [String: (name: String, imageURL: String, units: Int, revenue: Double)] = [:]
        
        for order in orders {
            for item in order.items {
                
                let revenueToAdd = item.unitPriceSnap * Double(item.quantity)
                
                if var entry = salesMap[item.productId] {
                    entry.units += item.quantity
                    entry.revenue += revenueToAdd
                    salesMap[item.productId] = entry
                } else {
                    salesMap[item.productId] = (
                        name: item.nameSnap,
                        imageURL: item.imageURLSnap,
                        units: item.quantity,
                        revenue: revenueToAdd
                    )
                }
            }
        }
        
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
            .sorted { $0.unitsSold > $1.unitsSold }
        

        var dailyMap: [Date: (units: Int, revenue: Double)] = [:]
        let calendar = Calendar.current
        
        for order in orders {
            let day = calendar.startOfDay(for: order.createdAt)
            
            let totalUnits = order.items.reduce(0) { $0 + $1.quantity }
            let totalRevenue = order.total
            
            if var entry = dailyMap[day] {
                entry.units += totalUnits
                entry.revenue += totalRevenue
                dailyMap[day] = entry
            } else {
                dailyMap[day] = (
                    units: totalUnits,
                    revenue: totalRevenue
                )
            }
        }
        
        let dailySales: [DailySales] = dailyMap
            .map { date, value in
                DailySales(
                    date: date,
                    units: value.units,
                    revenue: value.revenue
                )
            }
            .sorted { $0.date < $1.date }
        

        return SalesReport(
            period: period,
            totalRevenue: totalRevenue,
            totalOrders: totalOrders,
            totalUnitsSold: totalUnitsSold,
            topProducts: topProducts,
            dailySales: dailySales
        )
    }
}
