//
//  AdminOrdersView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct AdminOrdersView: View {

    @StateObject var viewModel: AdminOrdersViewModel
    @State private var showDatePicker  = false
    @State private var selectedOrder:  Order? = nil
    @State private var isShowingDetail = false
    let onLogout:  () -> Void
    let onSupport: () -> Void
    let onProfile: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground").ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    HStack {
                        Text("Pedidos")
                            .font(.title.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        Spacer()
                        ProfileMenuButton(
                            onLogout:     { onLogout() },
                            onSupport:    { onSupport() },
                            onProfile:    { onProfile() },
                            supportLabel: "Accede a soporte"
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
                        TextField("Busca por nombre del cliente", text: $viewModel.searchText)
                            .foregroundColor(Color("ColorPrimary"))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Color("ColorPrimary").opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // MARK: Date filter
                    HStack(spacing: 10) {
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color("ColorPrimary"))
                                Text(viewModel.selectedDate == nil
                                     ? "Seleccione una fecha"
                                     : formattedDate(viewModel.selectedDate!))
                                    .font(.subheadline)
                                    .foregroundColor(Color("ColorPrimary"))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color("ColorAccent").opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                        if viewModel.selectedDate != nil {
                            Button {
                                viewModel.clearDate()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color("ColorPrimary").opacity(0.5))
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // MARK: Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(OrderFilter.allCases, id: \.self) { filter in
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

                    // MARK: Orders list
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(Color("ColorSecondary"))
                        Spacer()
                    } else if viewModel.filteredOrders.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 44))
                                .foregroundColor(Color("ColorPrimary").opacity(0.3))
                            Text("No hay pedidos")
                                .foregroundColor(Color("ColorPrimary").opacity(0.5))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredOrders) { order in
                                    AdminOrderCard(
                                        order:    order,
                                        userName: viewModel.userNamesMap[order.userId] ?? "Cliente"
                                    ) {
                                        selectedOrder   = order
                                        isShowingDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .navigationDestination(isPresented: $isShowingDetail) {
                    if let order = selectedOrder {
                        AdminOrderDetailView(
                            order: Binding(
                                get: {
                                    viewModel.orders.first(where: { $0.id == order.id }) ?? order
                                },
                                set: { _ in }
                            ),
                            isUpdating: viewModel.isUpdating
                        ) { newStatus in
                            Task { await viewModel.updateStatus(order, newStatus: newStatus) }
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .task { await viewModel.loadOrders() }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(
                selectedDate: $viewModel.selectedDate,
                isPresented:  $showDatePicker
            )
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

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale    = Locale(identifier: "es_SV")
        return f.string(from: date)
    }
}

// MARK: - AdminOrderCard

struct AdminOrderCard: View {

    let order:    Order
    let userName: String
    let onUpdate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .center) {
                Text("ID: \(order.displayId)")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))

                if order.orderType == .wholesale {
                    StatusBadge(
                        title:      "Mayoreo",
                        background: Color("ColorPrimary"),
                        foreground: .white
                    )
                }

                StatusBadge(
                    title:      order.status.displayName,
                    background: badgeColor(for: order.status).opacity(0.15),
                    foreground: badgeColor(for: order.status)
                )

                Spacer()

                Text(order.formattedTotal)
                    .font(.headline.bold())
                    .foregroundColor(Color("ColorPrimary"))
            }

            Text(userName)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary").opacity(0.7))

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(Color("ColorPrimary").opacity(0.6))
                Text(order.formattedPickupTime)
                    .font(.caption)
                    .foregroundColor(Color("ColorPrimary").opacity(0.6))
            }

            Text(itemsSummary)
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.7))
                .lineLimit(2)

            Button(action: onUpdate) {
                Text("Actualizar")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color("ColorSecondary"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
    }

    private var itemsSummary: String {
        order.items
            .map { "\($0.nameSnap) x\($0.quantity)" }
            .joined(separator: ", ")
    }

    private func badgeColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending:        return Color("ColorSecondary")
        case .inPreparation:  return .blue
        case .readyForPickup: return .green
        case .delivered:      return Color("ColorPrimary")
        case .cancelled:      return .red
        }
    }
}

// MARK: - StatusBadge

struct StatusBadge: View {
    let title:      String
    let background: Color
    let foreground: Color

    var body: some View {
        Text(title)
            .font(.caption.bold())
            .foregroundColor(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title:      String
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : Color("ColorPrimary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("ColorPrimary") : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("ColorPrimary").opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - DatePickerSheet

struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    @Binding var isPresented:  Bool
    @State   private var tempDate = Date()

    var body: some View {
        NavigationStack {
            DatePicker("", selection: $tempDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color("ColorSecondary"))
                .padding()
                .navigationTitle("Seleccionar fecha")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { isPresented = false }
                            .foregroundColor(Color("ColorPrimary"))
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Aplicar") {
                            selectedDate = tempDate
                            isPresented  = false
                        }
                        .foregroundColor(Color("ColorSecondary"))
                        .bold()
                    }
                }
        }
        .presentationDetents([.medium])
    }
}
