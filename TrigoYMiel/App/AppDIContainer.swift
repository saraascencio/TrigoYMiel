//
//  AppDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine


final class AppDIContainer: ObservableObject {
    let authDIContainer = AuthDIContainer()
    let adminOrdersDIContainer = AdminOrdersDIContainer()
    let adminCatalogDIContainer = AdminCatalogDIContainer()
    let admininventoryDIContainer    = AdminInventoryDIContainer()
    let adminreportsDIContainer = AdminReportsDIContainer()
    let adminincidencesDIContainer   = AdminIncidencesDIContainer()
}
