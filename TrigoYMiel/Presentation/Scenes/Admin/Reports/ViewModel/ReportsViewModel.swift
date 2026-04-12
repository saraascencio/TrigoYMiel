//
//  ReportsViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

enum ReportPeriodFilter: String, CaseIterable {
    case thisWeek = "Esta semana"
    case thisMonth = "Este mes"
    case lastThreeMonths = "Últimos 3 meses"
}

enum ChartMode: String, CaseIterable {
    case units = "Unidades"
    case revenue = "Ingresos"
}

struct DayActivity: Identifiable {
    let id = UUID()
    let day: String
    let units: Int
    let revenue: Double
}

@MainActor
final class ReportsViewModel: ObservableObject {
    
    // MARK: - State
    @Published private(set) var report: SalesReport?
    @Published var isLoading = false
    @Published var isExporting = false
    @Published var errorMessage: String?
    
    @Published var selectedPeriod: ReportPeriodFilter = .thisWeek
    @Published var chartMode: ChartMode = .units
    
    @Published var activities: [DayActivity] = []
    
    // MARK: - Dependencies
    private let getSalesReportUseCase: GetSalesReportUseCase
    private let exportReportPDFUseCase: ExportReportPDFUseCase
    
    private var isRequestInProgress = false
    
    init(
        getSalesReportUseCase: GetSalesReportUseCase,
        exportReportPDFUseCase: ExportReportPDFUseCase
    ) {
        self.getSalesReportUseCase = getSalesReportUseCase
        self.exportReportPDFUseCase = exportReportPDFUseCase
    }
    
    // MARK: - Public Computed
    
    var totalUnitsSold: Int {
        report?.totalUnitsSold ?? 0
    }
    
    var totalRevenue: Double {
        report?.totalRevenue ?? 0
    }
    
    var reportFileName: String {
        guard let report else { return "Reporte.pdf" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let start = formatter.string(from: report.period.start)
        let end = formatter.string(from: report.period.end)
        
        return "Reporte_\(start)_a_\(end).pdf"
    }
    
    var totalOrders: Int {
        report?.totalOrders ?? 0
    }
    
    var averageDailyRevenue: Double {
        guard let report else { return 0 }
        let days = max(report.period.duration / 86400, 1)
        return report.totalRevenue / days
    }
    
    var bestDay: DayActivity? {
        activities.max(by: { $0.units < $1.units })
    }
    
    // MARK: - Actions
    
    func loadReport() async {
        guard !isRequestInProgress else { return }
        
        isRequestInProgress = true
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
            isRequestInProgress = false
        }
        
        do {
            let interval = buildInterval()
            let result = try await getSalesReportUseCase.execute(period: interval)
            
            report = result
            activities = buildActivities(from: result)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func changePeriod(_ period: ReportPeriodFilter) {
        selectedPeriod = period
        Task {
            await loadReport()
        }
    }
    
    func exportPDF() async -> Data? {
        guard let report else { return nil }
        
        isExporting = true
        defer { isExporting = false }
        
        do {
            return try await exportReportPDFUseCase.execute(report: report)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Private
    
    private func buildInterval() -> DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisWeek:
            let start = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            )!
            return DateInterval(start: start, end: now)
            
        case .thisMonth:
            let start = calendar.date(
                from: calendar.dateComponents([.year, .month], from: now)
            )!
            return DateInterval(start: start, end: now)
            
        case .lastThreeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: now)!
            return DateInterval(start: start, end: now)
        }
    }
    
    private func buildActivities(from report: SalesReport) -> [DayActivity] {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_SV")
        formatter.dateFormat = "EEEE"
        
        let orderedDays = [
            "Lunes", "Martes", "Miércoles",
            "Jueves", "Viernes", "Sábado", "Domingo"
        ]
        
        var map: [String: (units: Int, revenue: Double)] = [:]
        
        // Agrupar por día de la semana
        for item in report.dailySales {
            let dayName = formatter.string(from: item.date).capitalized
            
            if var entry = map[dayName] {
                entry.units += item.units
                entry.revenue += item.revenue
                map[dayName] = entry
            } else {
                map[dayName] = (item.units, item.revenue)
            }
        }
        
        // Construir resultado en orden fijo
        return orderedDays.map { day in
            let data = map[day] ?? (0, 0)
            
            return DayActivity(
                day: day,
                units: data.units,
                revenue: data.revenue
            )
        }
    }
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_SV")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}
