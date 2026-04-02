//
//  ReportRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - ReportRepository
// Protocolo para generación de reportes de ventas. Solo el admin lo usa.
// Los reportes se construyen consultando "pedidos" en Firestore
// filtrando por estado = "entregado" y el período indicado.

protocol ReportRepository {

    /// Reporte de ventas para el período dado. Solo admin.
    /// Solo incluye pedidos con status .delivered.
    /// Lanza: .unauthorized
    func getSalesReport(period: DateInterval) async throws -> SalesReport

    /// Genera los bytes de un PDF exportable del reporte. Solo admin.
    /// Lanza: .unauthorized
    func exportReportAsPDF(report: SalesReport) async throws -> Data
}
