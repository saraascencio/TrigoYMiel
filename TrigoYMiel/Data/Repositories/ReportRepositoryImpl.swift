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
        try Self.buildPDF(from: report)
    }

    // MARK: - PDF generation (client-side)

    @MainActor
    private static func buildPDF(from report: SalesReport) throws -> Data {

        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 pts
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { ctx in
            ctx.beginPage()

            let titleFont = UIFont.boldSystemFont(ofSize: 20)
            let bodyFont  = UIFont.systemFont(ofSize: 13)
            let smallFont = UIFont.systemFont(ofSize: 11)

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]

            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.darkGray
            ]

            let smallAttrs: [NSAttributedString.Key: Any] = [
                .font: smallFont,
                .foregroundColor: UIColor.gray
            ]

            var y: CGFloat = 40

            // MARK: - LOGO
            if let logo = UIImage(named: "LogoTrigoYMiel") {
                let logoRect = CGRect(x: 40, y: y, width: 50, height: 50)
                logo.draw(in: logoRect)
            }

            // MARK: - TITLE (DINÁMICO)
            let title = "Reporte de Ventas"
            let periodTitle = report.formattedPeriod

            let titleRect = CGRect(x: 100, y: y, width: 450, height: 25)
            title.draw(in: titleRect, withAttributes: titleAttrs)

            let periodRect = CGRect(x: 100, y: y + 25, width: 450, height: 20)
            periodTitle.draw(in: periodRect, withAttributes: smallAttrs)

            y += 80

            // MARK: - FECHA GENERACIÓN
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_SV")
            formatter.dateStyle = .medium
            formatter.timeStyle = .short

            let generated = "Generado: \(formatter.string(from: Date()))"
            draw(generated, attrs: smallAttrs, x: 40, y: &y, lineH: 20)

            y += 10

            // MARK: - KPIs
            draw("Ingresos totales:   \(report.formattedRevenue)", attrs: bodyAttrs, x: 40, y: &y, lineH: 22)
            draw("Total de pedidos:   \(report.totalOrders)", attrs: bodyAttrs, x: 40, y: &y, lineH: 22)
            draw("Unidades vendidas:  \(report.totalUnitsSold)", attrs: bodyAttrs, x: 40, y: &y, lineH: 22)

            y += 20

            // MARK: - TOP PRODUCTOS
            draw("Productos más vendidos", attrs: titleAttrs, x: 40, y: &y, lineH: 28)

            for (i, p) in report.topProducts.prefix(15).enumerated() {
                if y > 780 {
                    ctx.beginPage()
                    y = 40
                }

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
