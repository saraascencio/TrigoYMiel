//
//  GetSalesReportUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - GetSalesReportUseCase
// El admin obtiene el reporte de ventas para un período dado.
//
// Usado por: ReportsViewModel (Tab "Reportes" del admin)

final class GetSalesReportUseCase {

    private let reportRepository: ReportRepository

    init(reportRepository: ReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute(period: DateInterval) async throws -> SalesReport {
        try await reportRepository.getSalesReport(period: period)
    }
}
