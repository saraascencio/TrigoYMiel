//
//  AdminTabCoordinator.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct AdminTabCoordinator: View {
   
    let diContainer: AppDIContainer
    let currentUser: User
    let onLogout: () -> Void
  
    @State private var isShowingIncidences = false
   
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground")
                    .ignoresSafeArea()
                
                TabView {
                    AdminOrdersView(
                        viewModel: diContainer.adminOrdersDIContainer.makeAdminOrdersViewModel(),
                        onLogout: onLogout,
                        onSupport: { isShowingIncidences = true }
                    )
                    .tabItem {
                        Label("Pedidos", systemImage: "list.bullet.rectangle")
                    }
                   
                    AdminCatalogView(
                        viewModel: diContainer.adminCatalogDIContainer.makeAdminCatalogViewModel(),
                        diContainer: diContainer.adminCatalogDIContainer,
                        onLogout: onLogout,
                        onSupport: { isShowingIncidences = true }
                    )
                    .tabItem {
                        Label("Catálogo", systemImage: "square.grid.2x2")
                    }
                   
                    InventoryView(
                        viewModel: diContainer.admininventoryDIContainer.makeInventoryViewModel(),
                        adminId: currentUser.id,
                        onLogout: onLogout,
                        onSupport: { isShowingIncidences = true }
                    )
                    .tabItem {
                        Label("Inventario", systemImage: "archivebox")
                    }
                   
                    ReportsView(
                        viewModel: diContainer.adminreportsDIContainer.makeReportsViewModel(),
                        onLogout: onLogout,
                        onSupport: { isShowingIncidences = true }
                    )
                    .tabItem {
                        Label("Reportes", systemImage: "chart.bar")
                    }
                }
                .tint(Color("ColorSecondary"))
            }
            
            // Navegación y fullScreenCover fuera del ZStack (importante)
            .fullScreenCover(isPresented: $isShowingIncidences) {
                NavigationStack {
                    IncidencesView(
                        viewModel: diContainer.adminincidencesDIContainer.makeIncidencesViewModel(),
                        adminId: currentUser.id,
                        onLogout: onLogout,
                        onSupport: { isShowingIncidences = false }
                    )
                }
            }
        }
    }
}
