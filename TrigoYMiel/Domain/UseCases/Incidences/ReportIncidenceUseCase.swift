//
//  ReportIncidenceUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - ReportIncidenceUseCase
// El cliente reporta un problema desde SupportView.
// Construye la entidad Incidence y la envía al repositorio.
// Si hay imagen adjunta, el repositorio la sube a Firebase Storage.
//
// Usado por: SupportViewModel

final class ReportIncidenceUseCase {
    
    private let incidenceRepository: IncidenceRepository
    
    init(incidenceRepository: IncidenceRepository) {
        self.incidenceRepository = incidenceRepository
    }
    
    func execute(
        userId: String,
        orderId: String,
        type: IncidenceType,
        channel: ContactChannel,
        description: String,
        evidenceURL: String?
    ) async throws -> Incidence {
        
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.unknown("La descripción no puede estar vacía.")
        }
        
        let incidence = Incidence(
            id: UUID().uuidString,
            userId: userId,
            orderId: orderId,
            adminId: nil,
            type: type,
            channel: channel,
            description: description,
            evidenceURL: evidenceURL,       // el repositorio sube la imagen y llena este campo
            createdAt: Date(),
            status: .open,
            resolution: nil,
            resolvedAt: nil
        )
        
        return try await incidenceRepository.reportIncidence(incidence)
    }
    
    
}
