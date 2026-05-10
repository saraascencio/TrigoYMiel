//
//  AdminCatalogView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct AdminCatalogView: View {

    @StateObject var viewModel: AdminCatalogViewModel
    let diContainer: AdminCatalogDIContainer
    let onLogout:    () -> Void
    let onSupport:   () -> Void
    let onProfile:   () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground").ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Fila superior
                        HStack {
                            Spacer()

                            // Botón promociones
                            Button {
                                viewModel.showCreatePromo = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill")
                                    Text("Promos")
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(Color("ColorSecondary"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color("ColorSecondary").opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }

                            // Botón nuevo producto
                            Button {
                                viewModel.showCreateSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Producto")
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color("ColorSecondary"))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            
                            ProfileMenuButton(
                                onLogout: { onLogout() },
                                onSupport: { onSupport() },
                                onProfile: { onProfile() },
                                supportLabel: "Accede a soporte"
                            )
                            .padding(.leading, 4)
                        }

                        // Título
                        Text("Catálogo")
                            .font(.title.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        // MARK: Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("ColorPrimary").opacity(0.6))

                            TextField("Buscar producto", text: $viewModel.searchText)
                                .foregroundColor(Color("ColorPrimary"))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color("ColorPrimary").opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // MARK: Contenido principal
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView().tint(Color("ColorSecondary"))
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {

                                // ── 1. PROMOCIONES ACTIVAS ──
                                if !viewModel.promotions.isEmpty {
                                    promotionsSection
                                        .padding(.bottom, 16)
                                }

                                // ── 2. FILTRO CATEGORÍAS ──
                                categoriesChips
                                    .padding(.bottom, 12)

                                // ── 3. PRODUCTOS ──
                                if viewModel.filteredProducts.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "tray")
                                            .font(.system(size: 44))
                                            .foregroundColor(Color("ColorPrimary").opacity(0.3))
                                        Text("No hay productos")
                                            .foregroundColor(Color("ColorPrimary").opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)
                                } else {
                                    LazyVStack(spacing: 12) {
                                        ForEach(viewModel.filteredProducts) { product in
                                            AdminProductCard(
                                                product:      product,
                                                categoryName: viewModel.categoriesMap[product.categoryId] ?? product.categoryId
                                            ) {
                                                viewModel.productToEdit = product
                                                viewModel.showEditSheet = true
                                            } onDelete: {
                                                Task { await viewModel.deleteProduct(product) }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                                }
                            }
                        }
                    }
                }

                // MARK: NavigationDestinations
                .navigationDestination(isPresented: $viewModel.showCreatePromo) {
                    PromotionFormView(
                        viewModel: diContainer.makePromotionFormViewModel(
                            mode: .create
                        ) { newPromo in
                            viewModel.onPromotionSaved(newPromo, isNew: true)
                        }
                    )
                }
                .navigationDestination(isPresented: $viewModel.showEditPromo) {
                    if let promo = viewModel.promotionToEdit {
                        PromotionFormView(
                            viewModel: diContainer.makePromotionFormViewModel(
                                mode: .edit(promo)
                            ) { updated in
                                viewModel.onPromotionSaved(updated, isNew: false)
                            }
                        )
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .task { await viewModel.loadAll() }

        // MARK: Sheets — Producto
        .sheet(isPresented: $viewModel.showCreateSheet) {
            ProductFormView(
                viewModel: diContainer.makeProductFormViewModel(
                    mode:   .create,
                    onSave: { product in viewModel.onProductSaved(product, isNew: true) }
                ),
                categories: viewModel.categoriesList
            )
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            if let product = viewModel.productToEdit {
                ProductFormView(
                    viewModel: diContainer.makeProductFormViewModel(
                        mode:   .edit(product),
                        onSave: { updated in viewModel.onProductSaved(updated, isNew: false) }
                    ),
                    categories: viewModel.categoriesList
                )
            }
        }

        // MARK: Alert desactivar promoción
        .alert("¿Desactivar promoción?", isPresented: $viewModel.showDeactivateAlert) {
            Button("Cancelar", role: .cancel) {
                viewModel.promoToDeactivate = nil
            }
            Button("Desactivar", role: .destructive) {
                Task { await viewModel.confirmDeactivate() }
            }
        } message: {
            Text("La promoción dejará de mostrarse a los clientes. Puedes crear una nueva cuando quieras.")
        }

        // MARK: Alert error
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Sección promociones activas

    private var promotionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(Color("ColorSecondary"))
                        .font(.subheadline)
                    Text("Promociones activas")
                        .font(.title3.bold())
                        .foregroundColor(Color("ColorPrimary"))
                }
                Spacer()
                Text("\(viewModel.promotions.count)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color("ColorSecondary"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.promotions) { promotion in
                        PromoAdminCard(
                            promotion: promotion,
                            onEdit: {
                                viewModel.promotionToEdit = promotion
                                viewModel.showEditPromo   = true
                            },
                            onDeactivate: {
                                viewModel.requestDeactivate(promotion)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Chips categorías

    private var categoriesChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title:      "Todos",
                    isSelected: viewModel.selectedCategory == nil
                ) { viewModel.selectCategory(nil) }

                ForEach(viewModel.categoriesList) { cat in
                    FilterChip(
                        title:      cat.name,
                        isSelected: viewModel.selectedCategory == cat.id
                    ) { viewModel.selectCategory(cat.id) }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - PromoAdminCard

struct PromoAdminCard: View {

    let promotion:   Promotion
    let onEdit:      () -> Void
    let onDeactivate: () -> Void

    @State private var showConfirm = false

    private var formattedEnd: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale    = Locale(identifier: "es_SV")
        return f.string(from: promotion.endDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // MARK: Encabezado badge
            HStack {
                Text(promotion.formattedDiscount)
                    .font(.title2.bold())
                    .foregroundColor(Color("ColorSecondary"))
                Text("OFF")
                    .font(.caption.bold())
                    .foregroundColor(Color("ColorSecondary").opacity(0.7))

                Spacer()

                if promotion.wholesaleOnly {
                    Text("Mayoreo")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color("ColorPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }

            // Descripción
            Text(promotion.description)
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.65))
                .lineLimit(2)

            // Fecha fin
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
                Text("Hasta \(formattedEnd)")
                    .font(.caption2)
                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
            }

            // Productos
            Text("\(promotion.applicableProductIds.count) producto(s)")
                .font(.caption2)
                .foregroundColor(Color("ColorPrimary").opacity(0.4))

            Divider().opacity(0.5)

            // MARK: Acciones
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil").font(.caption.bold())
                        Text("Editar").font(.caption.bold())
                    }
                    .foregroundColor(Color("ColorPrimary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("ColorPrimary").opacity(0.25), lineWidth: 1)
                    )
                }

                Button {
                    showConfirm = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.slash").font(.caption.bold())
                        Text("Desactivar").font(.caption.bold())
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .confirmationDialog(
                    "¿Desactivar \"\(promotion.description)\"?",
                    isPresented: $showConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Desactivar", role: .destructive) { onDeactivate() }
                    Button("Cancelar",   role: .cancel) {}
                } message: {
                    Text("La promoción dejará de mostrarse a los clientes.")
                }
            }
        }
        .padding(14)
        .frame(width: 230)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("ColorAccent").opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - AdminProductCard

struct AdminProductCard: View {

    let product:      Product
    let categoryName: String
    let onEdit:       () -> Void
    let onDelete:     () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("ColorAccent").opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Color("ColorPrimary").opacity(0.3))
                        )
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline.bold())
                        .foregroundColor(Color("ColorPrimary"))
                    Text(categoryName)
                        .font(.caption)
                        .foregroundColor(Color("ColorPrimary").opacity(0.5))
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .foregroundColor(Color("ColorPrimary").opacity(0.8))
                }

                Spacer()

                VStack {
                    Text("\(product.stock)")
                        .font(.caption.bold())
                        .foregroundColor(product.stock <= 5 ? .red : Color("ColorPrimary"))
                    Text("uds")
                        .font(.caption2)
                        .foregroundColor(Color("ColorPrimary").opacity(0.4))
                }
            }

            Button(action: onEdit) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil").font(.caption.bold())
                    Text("Editar").font(.subheadline)
                }
                .foregroundColor(Color("ColorPrimary"))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("ColorPrimary").opacity(0.25), lineWidth: 1)
                )
            }
            .padding(.top, 12)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Eliminar producto", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "¿Eliminar \(product.name)?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) { onDelete() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("El producto quedará inactivo.")
        }
    }
}
