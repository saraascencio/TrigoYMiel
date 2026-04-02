//
//  ExportReportPDFUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - ExportReportPDFUseCase
// Genera los bytes del PDF del reporte para compartir o guardar.
// El ViewModel los pasa a ShareSheet de SwiftUI.
//
// Usado por: ReportsViewModel (botón exportar en ReportsView)

final class ExportReportPDFUseCase {

    private let reportRepository: ReportRepository

    init(reportRepository: ReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute(report: SalesReport) async throws -> Data {
        try await reportRepository.exportReportAsPDF(report: report)
    }
}
