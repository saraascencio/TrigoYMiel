//
//  SalesReport.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - SalesReport
// Resumen de ventas para un período determinado.
// Construido por GetSalesReportUseCase a partir de los pedidos en Firestore.
// Mostrado en ReportsView (Admin).

struct SalesReport: Equatable {
    let period: DateInterval            // período del reporte (inicio → fin)
    let totalRevenue: Double            // ingresos totales del período
    let totalOrders: Int                // número de pedidos entregados
    let totalUnitsSold: Int             // total de unidades vendidas
    let topProducts: [ProductSalesSummary] // productos más vendidos

    // MARK: - Computed helpers

    var formattedRevenue: String {
        String(format: "$%.2f", totalRevenue)
    }

    var formattedPeriod: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_SV")
        let start = formatter.string(from: period.start)
        let end   = formatter.string(from: period.end)
        return "\(start) – \(end)"
    }
}

// MARK: - ProductSalesSummary
// Resumen de ventas de un producto individual dentro de un SalesReport.

struct ProductSalesSummary: Identifiable, Equatable {
    let id: String          // producto_id
    let productName: String // nombre_snap del producto
    let imageURL: String    // imagen del producto
    let unitsSold: Int      // unidades vendidas en el período
    let revenue: Double     // ingresos generados por este producto

    var formattedRevenue: String {
        String(format: "$%.2f", revenue)
    }
}

// MARK: - ReportPeriod
// Períodos predefinidos para el filtro de reportes (PeriodFilterView).

enum ReportPeriod: String, CaseIterable {
    case today       = "Hoy"
    case thisWeek    = "Esta semana"
    case thisMonth   = "Este mes"
    case lastMonth   = "Mes anterior"
    case custom      = "Personalizado"

    /// Calcula el DateInterval correspondiente a cada período
    func toDateInterval() -> DateInterval {
        let calendar = Calendar.current
        let now      = Date()

        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            return DateInterval(start: start, end: now)
        case .thisWeek:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return DateInterval(start: start, end: now)
        case .thisMonth:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return DateInterval(start: start, end: now)
        case .lastMonth:
            let thisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let start     = calendar.date(byAdding: .month, value: -1, to: thisMonth)!
            let end       = calendar.date(byAdding: .day, value: -1, to: thisMonth)!
            return DateInterval(start: start, end: end)
        case .custom:
            // Para .custom, el ViewModel pasa las fechas directamente
            return DateInterval(start: now, end: now)
        }
    }
}
