//
//  FilterReportByPeriodUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - FilterReportByPeriodUseCase
// Calcula el DateInterval a partir de un ReportPeriod seleccionado.
// Para .custom el ViewModel pasa las fechas manualmente.
// No necesita repositorio — toda la lógica es local.
//
// Usado por: ReportsViewModel (PeriodFilterView)

final class FilterReportByPeriodUseCase {

    func execute(
        reportPeriod: ReportPeriod,
        customStart: Date? = nil,
        customEnd: Date? = nil
    ) throws -> DateInterval {

        if reportPeriod == .custom {
            guard let start = customStart, let end = customEnd else {
                throw AppError.unknown("Debes seleccionar fecha de inicio y fin.")
            }
            guard start < end else {
                throw AppError.unknown("La fecha de inicio debe ser anterior a la fecha de fin.")
            }
            return DateInterval(start: start, end: end)
        }

        return reportPeriod.toDateInterval()
    }
}
