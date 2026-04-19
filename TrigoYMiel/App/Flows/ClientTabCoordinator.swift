//
//  ClientTabCoordinator.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
// App/Flows/ClientTabCoordinator.swift

// App/Flows/ClientTabCoordinator.swift

/*import SwiftUI

struct ClientTabCoordinator: View {
    
    let diContainer: AppDIContainer
    let currentUser: User
    let onLogout: () -> Void
    
    @State private var isShowingSupport = false
    @State private var selectedProduct: Product? = nil   // Para navegar al detalle
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground")
                    .ignoresSafeArea()
                
                TabView {
                    CatalogView(
                        viewModel: diContainer.catalogDIContainer.makeCatalogViewModel(),
                        currentUser: currentUser,
                        onLogout: onLogout,
                        onSupport: { isShowingSupport = true },
                        onCartTap: { /* TODO: Implementar carrito */ },
                        onProductSelected: { product in
                            selectedProduct = product
                        }
                    )
                    .tabItem {
                        Label("Catálogo", systemImage: "magnifyingglass")
                    }
                    
                    Text("En curso — pendiente")
                        .tabItem {
                            Label("En curso", systemImage: "clock")
                        }
                    
                    Text("Historial — pendiente")
                        .tabItem {
                            Label("Historial", systemImage: "archivebox")
                        }
                    
                    Text("Mayoreo — pendiente")
                        .tabItem {
                            Label("Mayoreo", systemImage: "plus")
                        }
                }
                .tint(Color("ColorSecondary"))
            }
            
            // Navegación al detalle del producto (compatible con iOS 16)
            .navigationDestination(isPresented: Binding(
                get: { selectedProduct != nil },
                set: { if !$0 { selectedProduct = nil } }
            )) {
                if let product = selectedProduct {
                    ProductDetailView(
                        product: product,
                        currentUser: currentUser,
                        diContainer: diContainer
                    )
                }
            }
            
            // Soporte
            .navigationDestination(isPresented: $isShowingSupport) {
                Text("Soporte cliente — pendiente")
            }
        }
    }
}*/
/*import SwiftUI

struct ClientTabCoordinator: View {

    let diContainer: AppDIContainer
    let currentUser: User
    let onLogout:    () -> Void

    @State private var isShowingCart    = false
    @State private var isShowingSupport = false
    @State private var isShowingProduct = false
    @State private var selectedProduct: Product? = nil

    var body: some View {
        NavigationStack {
            TabView {

                // MARK: Tab Catálogo
                CatalogView(
                    viewModel:         diContainer.catalogDIContainer.makeCatalogViewModel(),
                    currentUser:       currentUser,
                    onLogout:          onLogout,
                    onSupport:         { isShowingSupport = true },
                    onCartTap:         { isShowingCart    = true },
                    onProductSelected: { product in
                        selectedProduct  = product
                        isShowingProduct = true
                    }
                )
                .tabItem { Label("Catálogo",  systemImage: "magnifyingglass") }

                Text("En curso — pendiente")
                    .tabItem { Label("En curso",  systemImage: "clock") }

                Text("Historial — pendiente")
                    .tabItem { Label("Historial", systemImage: "archivebox") }

                Text("Mayoreo — pendiente")
                    .tabItem { Label("Mayoreo",   systemImage: "plus") }
            }
            .tint(Color("ColorSecondary"))
            .navigationBarHidden(true)

            // MARK: Carrito
            .navigationDestination(isPresented: $isShowingCart) {
                CartView(
                    viewModel: diContainer.cartDIContainer
                        .makeCartViewModel(currentUser: currentUser),
                    onLogout:  onLogout,
                    onSupport: { isShowingSupport = true }
                )
            }

            // MARK: Detalle de producto
            .navigationDestination(isPresented: $isShowingProduct) {
                if let product = selectedProduct {
                    ProductDetailView(
                        product:     product,
                        currentUser: currentUser,
                        diContainer: diContainer
                    )
                }
            }

            // MARK: Soporte cliente — pendiente
            .navigationDestination(isPresented: $isShowingSupport) {
                Text("Soporte cliente — pendiente")
            }
        }
    }
}*/
/*import SwiftUI

struct ClientTabCoordinator: View {

    let diContainer: AppDIContainer
    let currentUser: User
    let onLogout:    () -> Void

    @State private var isShowingCart    = false
    @State private var isShowingSupport = false
    @State private var isShowingProduct = false
    @State private var selectedProduct: Product? = nil
    @State private var isShowingOrderDetail = false
    @State private var selectedOrder: Order? = nil
    
    var body: some View {
        NavigationStack {
            TabView {

                // MARK: Tab Catálogo
                CatalogView(
                    viewModel:         diContainer.catalogDIContainer.makeCatalogViewModel(),
                    currentUser:       currentUser,
                    onLogout:          onLogout,
                    onSupport:         { isShowingSupport = true },
                    onCartTap:         { isShowingCart    = true },
                    onProductSelected: { product in
                        selectedProduct  = product
                        isShowingProduct = true
                    }
                )
                .tabItem { Label("Catálogo", systemImage: "magnifyingglass") }

                // MARK: Tab En curso
                ActiveOrdersView(
                    viewModel: diContainer.orderDIContainer.makeActiveOrdersViewModel(userId: currentUser.id),
                    onLogout: onLogout,
                    onSupport: { isShowingSupport = true },
                    onCartTap: { isShowingCart = true },
                    onOrderSelected: { order in
                        selectedOrder = order
                        isShowingOrderDetail = true
                    }
                )
                .tabItem { Label("En curso", systemImage: "clock") }
                // MARK: Tab Historial
                OrderHistoryView(
                    viewModel: diContainer.orderDIContainer
                        .makeOrderHistoryViewModel(userId: currentUser.id),
                    onLogout:  onLogout,
                    onSupport: { isShowingSupport = true },
                    onCartTap: { isShowingCart    = true }
                )
                .tabItem { Label("Historial", systemImage: "archivebox") }

                // MARK: Tab Mayoreo
                WholesaleView(
                    viewModel: diContainer.wholesaleDIContainer
                        .makeWholesaleViewModel(currentUser: currentUser),
                    onLogout:  onLogout,
                    onSupport: { isShowingSupport = true },
                    onCartTap: { isShowingCart    = true }
                )
                .tabItem { Label("Mayoreo", systemImage: "plus") }
            }
            .tint(Color("ColorSecondary"))
            .navigationBarHidden(true)

            // MARK: Carrito
            .navigationDestination(isPresented: $isShowingCart) {
                CartView(
                    viewModel: diContainer.cartDIContainer
                        .makeCartViewModel(currentUser: currentUser),
                    onLogout:  onLogout,
                    onSupport: { isShowingSupport = true }
                )
            }

            // MARK: Detalle de producto
            .navigationDestination(isPresented: $isShowingProduct) {
                if let product = selectedProduct {
                    ProductDetailView(
                        product:     product,
                        currentUser: currentUser,
                        diContainer: diContainer
                    )
                }
            }

            // MARK: Soporte cliente
            .navigationDestination(isPresented: $isShowingSupport) {
                Text("Soporte cliente — pendiente")
            }
        }
    }
}*/

import SwiftUI

struct ClientTabCoordinator: View {

    let diContainer: AppDIContainer
    let currentUser: User
    let onLogout:    () -> Void

    @State private var isShowingCart          = false
    @State private var isShowingWholesaleCart = false
    @State private var isShowingSupport       = false
    @State private var isShowingProduct       = false
    @State private var selectedProduct:  Product?    = nil
    @State private var wholesalePromotions: [Promotion] = []
    @State private var isShowingOrderDetail = false
    @State private var selectedOrder: Order? = nil
    
    var body: some View {
        NavigationStack {
            TabView {

                // MARK: Tab Catálogo
                CatalogView(
                    viewModel:         diContainer.catalogDIContainer.makeCatalogViewModel(),
                    onLogout:          onLogout,
                    onSupport:         { isShowingSupport = true },
                    onCartTap:         { isShowingCart    = true },
                    onProductSelected: { product in
                        selectedProduct  = product
                        isShowingProduct = true
                    }
                )
                .tabItem { Label("Catálogo", systemImage: "magnifyingglass") }

                // MARK: Tab En curso
                ActiveOrdersView(
                    viewModel: diContainer.orderDIContainer.makeActiveOrdersViewModel(userId: currentUser.id),
                    onLogout: onLogout,
                    onSupport: { isShowingSupport = true },
                    onCartTap: { isShowingCart = true },
                    onOrderSelected: { order in
                        selectedOrder = order
                        isShowingOrderDetail = true
                    }
                )
                .tabItem { Label("En curso", systemImage: "clock") }
                // MARK: Tab Historial
                OrderHistoryView(
                    viewModel: diContainer.orderDIContainer
                        .makeOrderHistoryViewModel(userId: currentUser.id),
                    onLogout:  onLogout,
                    onSupport: { isShowingSupport = true },
                    onCartTap: { isShowingCart    = true }
                )
                .tabItem { Label("Historial", systemImage: "archivebox") }

                // MARK: Tab Mayoreo
                WholesaleView(
                    viewModel: diContainer.wholesaleDIContainer
                        .makeWholesaleViewModel(currentUser: currentUser),
                    onLogout:        onLogout,
                    onSupport:       { isShowingSupport       = true },
                    onWholesaleCart: { isShowingWholesaleCart = true }
                )
                .tabItem { Label("Mayoreo", systemImage: "plus") }
            }
            .tint(Color("ColorSecondary"))
            .navigationBarHidden(true)

            // MARK: Carrito minorista
            .navigationDestination(isPresented: $isShowingCart) {
                CartView(
                    viewModel: diContainer.cartDIContainer
                        .makeCartViewModel(currentUser: currentUser),
                    onLogout:  onLogout,
                    onSupport: { isShowingSupport = true }
                )
            }

            // MARK: Detalle de producto
            .navigationDestination(isPresented: $isShowingProduct) {
                if let product = selectedProduct {
                    ProductDetailView(
                        product:     product,
                        currentUser: currentUser,
                        diContainer: diContainer
                    )
                }
            }
            
            .navigationDestination(isPresented: $isShowingOrderDetail) {
                if let order = selectedOrder {
                    OrderDetailView(
                        order: order,
                        updateOrderStatusUseCase: diContainer.orderDIContainer.makeUpdateOrderStatusUseCase()
                    )
                }
            }
            // MARK: Soporte cliente
            .navigationDestination(isPresented: $isShowingSupport) {
                SupportView(
                    viewModel: diContainer.incidencesDIContainer.makeSupportViewModel(currentUser: currentUser)
                )
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .wholesalePromotionsLoaded)
        ) { notification in
            if let promos = notification.object as? [Promotion] {
                wholesalePromotions = promos
            }
        }
    }
}

// MARK: - Notification para pasar promociones al carrito mayorista
extension Notification.Name {
    static let wholesalePromotionsLoaded = Notification.Name("wholesalePromotionsLoaded")
}
