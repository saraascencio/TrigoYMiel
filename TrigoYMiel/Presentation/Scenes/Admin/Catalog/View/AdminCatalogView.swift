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
    let onLogout:  () -> Void
    let onSupport: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground").ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    HStack {
                        Text("Catálogo")
                            .font(.title.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        Spacer()
                        Button {
                            viewModel.showCreateSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus").font(.subheadline.bold())
                                Text("Crear").font(.subheadline.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("ColorSecondary"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        ProfileMenuButton(
                            onLogout:     { onLogout() },
                            onSupport:    { onSupport() },
                            supportLabel: "Accede a soporte"  // abre IncidencesView
                        )
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // MARK: Category chips
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
                    .padding(.bottom, 12)

                    // MARK: List
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView().tint(Color("ColorSecondary"))
                        Spacer()
                    } else if viewModel.filteredProducts.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 44))
                                .foregroundColor(Color("ColorPrimary").opacity(0.3))
                            Text("No hay productos")
                                .foregroundColor(Color("ColorPrimary").opacity(0.5))
                        }
                        Spacer()
                    } else {
                        ScrollView {
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
            .navigationBarHidden(true)
        }
        .task { await viewModel.loadProducts() }
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
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
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
            Text("El producto quedará inactivo. Los pedidos históricos no se verán afectados.")
        }
    }
}
