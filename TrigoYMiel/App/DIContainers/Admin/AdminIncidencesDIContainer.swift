//
//  AdminIncidencesDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 11/4/26.
//

import Foundation

final class AdminIncidencesDIContainer {

    private let incidenceRepository: IncidenceRepository = IncidenceRepositoryImpl()

    func makeGetIncidencesUseCase() -> GetIncidencesUseCase {
        GetIncidencesUseCase(incidenceRepository: incidenceRepository)
    }

    func makeResolveIncidenceUseCase() -> ResolveIncidenceUseCase {
        ResolveIncidenceUseCase(incidenceRepository: incidenceRepository)
    }

    func makeIncidencesViewModel() -> IncidencesViewModel {
        IncidencesViewModel(
            getIncidencesUseCase:    makeGetIncidencesUseCase(),
            resolveIncidenceUseCase: makeResolveIncidenceUseCase()
        )
    }
}
