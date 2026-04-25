//
//  InventoryView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct InventoryView: View {

    @StateObject var viewModel: InventoryViewModel
    let adminId: String

    @State private var isShowingMovement = false
    @State private var selectedEntry: InventoryEntry? = nil
    let onLogout:  () -> Void
    let onSupport: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground").ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    HStack {
                        Text("Inventario")
                            .font(.title.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        Spacer()
                        ProfileMenuButton(
                            onLogout:     { onLogout() },
                            onSupport:    { onSupport() },
                            supportLabel: "Accede a soporte"  
                        )
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

                    // MARK: Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(InventoryFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title:      filter.rawValue,
                                    isSelected: viewModel.selectedFilter == filter
                                ) {
                                    viewModel.selectedFilter = filter
                                }
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
                    } else if viewModel.filteredInventory.isEmpty {
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
                                ForEach(viewModel.filteredInventory) { entry in
                                    InventoryCard(
                                        entry:       entry,
                                        isAvailable: viewModel.availabilityMap[entry.id] ?? true,
                                        onEntry: {
                                            selectedEntry     = entry
                                            isShowingMovement = true
                                        },
                                        onExit: {
                                            selectedEntry     = entry
                                            isShowingMovement = true
                                        },
                                        onToggle: {
                                            Task { await viewModel.toggleProductAvailability(entry) }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .navigationDestination(isPresented: $isShowingMovement) {
                    if let entry = selectedEntry {
                        StockMovementFormView(
                            entry:        entry,
                            isSubmitting: viewModel.isSubmitting
                        ) { type, quantity, note in
                            Task {
                                if type == .entry {
                                    await viewModel.registerEntry(
                                        productId: entry.id,
                                        quantity:  quantity,
                                        note:      note,
                                        adminId:   adminId
                                    )
                                } else {
                                    await viewModel.registerExit(
                                        productId: entry.id,
                                        quantity:  quantity,
                                        note:      note,
                                        adminId:   adminId
                                    )
                                }
                                isShowingMovement = false
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .task { await viewModel.loadInventory() }
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

// MARK: - InventoryCard

struct InventoryCard: View {

    let entry:       InventoryEntry
    let isAvailable: Bool
    let onEntry:     () -> Void
    let onExit:      () -> Void
    let onToggle:    () -> Void

    @State private var isActive: Bool

    init(
        entry:       InventoryEntry,
        isAvailable: Bool,
        onEntry:     @escaping () -> Void,
        onExit:      @escaping () -> Void,
        onToggle:    @escaping () -> Void
    ) {
        self.entry       = entry
        self.isAvailable = isAvailable
        self.onEntry     = onEntry
        self.onExit      = onExit
        self.onToggle    = onToggle
        _isActive        = State(initialValue: isAvailable)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {

                // Imagen
                AsyncImage(url: URL(string: entry.imageURL)) { image in
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
                    Text(entry.productName)
                        .font(.subheadline.bold())
                        .foregroundColor(Color("ColorPrimary"))

                    if !isActive {
                        Text("Inactivo")
                            .font(.caption.bold())
                            .foregroundColor(.red)
                    } else if entry.isLowStock && entry.currentStock > 0 {
                        Text("Stock bajo")
                            .font(.caption.bold())
                            .foregroundColor(Color("ColorSecondary"))
                    } else if entry.currentStock == 0 {
                        Text("Agotado")
                            .font(.caption.bold())
                            .foregroundColor(.red)
                    } else {
                        Text("Activo")
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()

                // Stock + Toggle
                VStack(alignment: .trailing, spacing: 6) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(entry.currentStock)")
                            .font(.title2.bold())
                            .foregroundColor(
                                entry.currentStock == 0
                                ? .red
                                : entry.isLowStock
                                ? Color("ColorSecondary")
                                : Color("ColorPrimary")
                            )
                        Text("unidades")
                            .font(.caption2)
                            .foregroundColor(Color("ColorPrimary").opacity(0.4))
                    }

                    Toggle("", isOn: $isActive)
                        .labelsHidden()
                        .tint(Color("ColorSecondary"))
                        .scaleEffect(0.85)
                        .onChange(of: isActive) { _ in
                            onToggle()
                        }
                }
            }

            // Botones Entrada / Salida
            HStack(spacing: 10) {
                Button(action: onEntry) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle")
                            .font(.caption.bold())
                        Text("Entrada")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color("ColorPrimary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("ColorPrimary").opacity(0.25), lineWidth: 1)
                    )
                }

                Button(action: onExit) {
                    HStack(spacing: 6) {
                        Image(systemName: "minus.circle")
                            .font(.caption.bold())
                        Text("Salida")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color("ColorPrimary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("ColorPrimary").opacity(0.25), lineWidth: 1)
                    )
                }
            }
            .padding(.top, 12)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
