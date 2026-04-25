//
//  AdminReportsDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 9/4/26.
//
import Foundation

final class AdminReportsDIContainer {

    private let reportRepository: ReportRepository = ReportRepositoryImpl()

    func makeGetSalesReportUseCase() -> GetSalesReportUseCase {
        GetSalesReportUseCase(reportRepository: reportRepository)
    }

    func makeFilterReportByPeriodUseCase() -> FilterReportByPeriodUseCase {
        FilterReportByPeriodUseCase()
    }

    func makeExportReportPDFUseCase() -> ExportReportPDFUseCase {
        ExportReportPDFUseCase(reportRepository: reportRepository)
    }

    func makeReportsViewModel() -> ReportsViewModel {
            ReportsViewModel(
            getSalesReportUseCase:      makeGetSalesReportUseCase(),
            //filterReportByPeriodUseCase: makeFilterReportByPeriodUseCase(),
            exportReportPDFUseCase:     makeExportReportPDFUseCase()
        )
    }
}
