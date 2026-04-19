//
//  CatalogView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
// Presentation/Scenes/Catalog/View/CatalogView.swift
import SwiftUI

struct CatalogView: View {
    @StateObject var viewModel: CatalogViewModel
    let onLogout: () -> Void
    let onSupport: () -> Void
    let onCartTap: () -> Void
    let onProductSelected: (Product) -> Void
    
   
    @State private var showClosedAlert = false
    
    // MARK: - Lógica de Horario El Salvador
    private var isStoreOpen: Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/El_Salvador") ?? TimeZone(identifier: "CST")!
        let hour = calendar.component(.hour, from: Date())
        return hour >= 10 && hour < 20
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: Header con Estado de Tienda
                        HStack {
                            // Badge de Abierto/Cerrado
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isStoreOpen ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                Text(isStoreOpen ? "Abierto" : "Cerrado")
                                    .font(.caption.bold())
                                    .foregroundColor(isStoreOpen ? .green : .red)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background((isStoreOpen ? Color.green : Color.red).opacity(0.1))
                            .clipShape(Capsule())
                            
                            Spacer()
                            
                            
                            ClientMenuButton(
                                    onLogout: { onLogout() },
                                    onSupport: { onSupport() },
                                    onCartTap: { onCartTap() }
                                )
                            
                            .padding(.leading, 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                        // MARK: Saludo Dinámico
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bienvenido")
                                .font(.title.bold())
                                .foregroundColor(Color("ColorPrimary"))
                            Text(isStoreOpen ? "¿Listo para tu pedido?" : "Abierto de 10:00am a 8:00pm")
                                .font(.title2.bold())
                                .foregroundColor(Color("ColorPrimary").opacity(isStoreOpen ? 1 : 0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                        // MARK: Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("ColorPrimary").opacity(0.6))
                            TextField("Busca tu pan favorito", text: $viewModel.searchText)
                                .foregroundColor(Color("ColorPrimary"))
                                .onChange(of: viewModel.searchText) { newValue in
                                    Task { await viewModel.search() }
                                }
                            if !viewModel.searchText.isEmpty {
                                Button { viewModel.clearSearch() } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color("ColorPrimary").opacity(0.4))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color("ColorPrimary").opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(Color("ColorSecondary"))
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                        }
                        else if viewModel.isSearching {
                            searchResultsSection
                        } else {
                            // MARK: Categorías
                            categoriasSection
                            
                            // MARK: Populares
                            if !viewModel.popularProducts.isEmpty {
                                popularesSection
                            }
                            
                            // MARK: Por categoría
                            ForEach(viewModel.productsByCategory, id: \.category.id) { group in
                                categorySection(group.category, products: group.products)
                            }
                        }
                        
                        Spacer(minLength: 32)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task { await viewModel.loadCatalog() }
        .alert("Tienda Cerrada", isPresented: $showClosedAlert) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text("Nuestro horario de pedidos es de 10:00 am a 8:00 pm (El Salvador). ¡Te esperamos!")
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Helper de Navegación Protegida
    private func selectProduct(_ product: Product) {
        if isStoreOpen {
            onProductSelected(product)
        } else {
            showClosedAlert = true
        }
    }
    
    // MARK: - Secciones Refactorizadas
    
    private var categoriasSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Categorías")
                .font(.title3.bold())
                .foregroundColor(Color("ColorPrimary"))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.categories) { cat in
                        let isSelected = viewModel.selectedCategory?.id == cat.id
                        Button {
                            withAnimation(.spring()) { viewModel.selectCategory(cat) }
                        } label: {
                            Text(cat.name)
                                .font(.subheadline)
                                .fontWeight(isSelected ? .bold : .regular)
                                .foregroundColor(isSelected ? .white : Color("ColorPrimary"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color("ColorPrimary") : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("ColorPrimary").opacity(0.3), lineWidth: isSelected ? 0 : 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
    
    private var popularesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Populares")
                .font(.title3.bold())
                .foregroundColor(Color("ColorPrimary"))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.popularProducts) { product in
                        PopularProductCard(product: product) {
                            selectProduct(product)
                        }
                        .opacity(isStoreOpen ? 1 : 0.7)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    private func categorySection(_ category: ProductCategory, products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.name)
                .font(.title3.bold())
                .foregroundColor(Color("ColorPrimary"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(products) { product in
                    CatalogProductRow(
                        product: product,
                        isOnPromotion: viewModel.shouldShowPromotion(for: product) // <--- Aquí está la clave
                    ) {
                        selectProduct(product)
                    }
                    .opacity(isStoreOpen ? 1 : 0.7)
                    if product.id != products.last?.id {
                        Divider().padding(.horizontal, 20)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resultados")
                .font(.title3.bold())
                .foregroundColor(Color("ColorPrimary"))
                .padding(.horizontal, 20)
            
            if viewModel.searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundColor(Color("ColorPrimary").opacity(0.3))
                    Text("No encontramos \"\(viewModel.searchText)\"")
                        .foregroundColor(Color("ColorPrimary").opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.searchResults) { product in
                        CatalogProductRow(
                            product: product,
                            isOnPromotion: viewModel.isProductOnPromotion(product: product) // <--- Aquí está la clave
                        ) {
                            selectProduct(product)
                        }
                        if product.id != viewModel.searchResults.last?.id {
                            Divider().padding(.horizontal, 20)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Subviews Reutilizables

struct PopularProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: product.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Color("ColorAccent").opacity(0.3)
                    default: Color("ColorAccent").opacity(0.2).overlay(ProgressView())
                    }
                }
                .frame(width: 140, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(product.name)
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
                    .lineLimit(2)
                    .frame(width: 140, alignment: .leading)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .foregroundColor(Color("ColorPrimary").opacity(0.7))
            }
            .frame(width: 140)
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CatalogProductRow: View {
    let product: Product
    let isOnPromotion: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                                            
                                            if isOnPromotion {
                                                Text("PROMO")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.red)
                                                    .foregroundColor(.white)
                                                    .clipShape(Capsule())
                                            }
                                        }
                    Text(product.name)
                        .font(.subheadline.bold())
                        .foregroundColor(Color("ColorPrimary"))
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(Color("ColorPrimary").opacity(0.55))
                        .lineLimit(2)
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .foregroundColor(Color("ColorPrimary").opacity(0.8))
                }
                Spacer()
                AsyncImage(url: URL(string: product.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Color("ColorAccent").opacity(0.3)
                    default: Color("ColorAccent").opacity(0.2).overlay(ProgressView().scaleEffect(0.7))
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
