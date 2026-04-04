//
//  ReportRepositoryImpl.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import UIKit

// MARK: - ReportRepositoryImpl
// Reportes calculados en cliente. PDF generado localmente con UIKit.

final class ReportRepositoryImpl: ReportRepository {

    private let remoteDataSource = ReportFirestoreDataSource()

    func getSalesReport(period: DateInterval) async throws -> SalesReport {
        try await remoteDataSource.getSalesReport(period: period)
    }

    func exportReportAsPDF(report: SalesReport) throws -> Data {
        // buildPDF corre en el MainActor, no necesita await
        try Self.buildPDF(from: report)
    }

    // MARK: - PDF generation (client-side)

    @MainActor
    private static func buildPDF(from report: SalesReport) throws -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 pts
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { ctx in
            ctx.beginPage()

            let titleFont = UIFont.boldSystemFont(ofSize: 22)
            let bodyFont  = UIFont.systemFont(ofSize: 13)
            let smallFont = UIFont.systemFont(ofSize: 11)

            let titleAttrs: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
            let bodyAttrs:  [NSAttributedString.Key: Any] = [.font: bodyFont,  .foregroundColor: UIColor.darkGray]
            let smallAttrs: [NSAttributedString.Key: Any] = [.font: smallFont, .foregroundColor: UIColor.gray]

            var y: CGFloat = 44

            // Header
            draw("Reporte de Ventas — Trigo y Miel", attrs: titleAttrs, x: 40, y: &y, lineH: 32)
            draw("Período: \(report.formattedPeriod)", attrs: smallAttrs, x: 40, y: &y, lineH: 24)

            y += 12

            // Summary
            draw("Ingresos totales:   \(report.formattedRevenue)", attrs: bodyAttrs, x: 40, y: &y, lineH: 22)
            draw("Total de pedidos:   \(report.totalOrders)",      attrs: bodyAttrs, x: 40, y: &y, lineH: 22)
            draw("Unidades vendidas:  \(report.totalUnitsSold)",   attrs: bodyAttrs, x: 40, y: &y, lineH: 22)

            y += 16
            draw("Productos más vendidos", attrs: titleAttrs, x: 40, y: &y, lineH: 28)

            for (i, p) in report.topProducts.prefix(15).enumerated() {
                if y > 780 { ctx.beginPage(); y = 44 }
                let line = "\(i + 1).  \(p.productName)  ·  \(p.unitsSold) uds  ·  \(p.formattedRevenue)"
                draw(line, attrs: bodyAttrs, x: 40, y: &y, lineH: 20)
            }
        }
    }

    private static func draw(
        _ text: String,
        attrs: [NSAttributedString.Key: Any],
        x: CGFloat,
        y: inout CGFloat,
        lineH: CGFloat
    ) {
        NSAttributedString(string: text, attributes: attrs)
            .draw(at: CGPoint(x: x, y: y))
        y += lineH
    }
}
