//
//  ActiveOrdersView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 16/4/26.
//
import SwiftUI

struct ActiveOrdersView: View {

    @StateObject var viewModel: ActiveOrdersViewModel
    let onLogout:  () -> Void
    let onSupport: () -> Void
    let onCartTap: () -> Void
    let onProfile: () -> Void
    
    let onOrderSelected: (Order) -> Void

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Header
                HStack {
                    Spacer()
                    ClientMenuButton(
                            onLogout: { onLogout() },
                            onSupport: { onSupport() },
                            onCartTap: { onCartTap() },
                            onProfile:    { onProfile() }
                    )
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // MARK: - Título
                Text("Pedidos en curso")
                    .font(.title.bold())
                    .foregroundColor(Color("ColorPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // MARK: - Contenido
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(Color("ColorSecondary"))
                    Spacer()

                } else if viewModel.orders.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.orders) { order in
                                
                                Button {
                                    onOrderSelected(order)
                                } label: {
                                    ActiveOrderCard(order: order)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .task { await viewModel.loadOrders() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Subvistas
    private var emptyStateView: some View {
        VStack {
            Spacer()
            VStack(spacing: 14) {
                Image(systemName: "clock")
                    .font(.system(size: 52))
                    .foregroundColor(Color("ColorPrimary").opacity(0.2))
                Text("No tienes pedidos en curso")
                    .font(.title3.bold())
                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
                Text("Tus pedidos activos aparecerán aquí")
                    .font(.subheadline)
                    .foregroundColor(Color("ColorPrimary").opacity(0.3))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
    }
}

// MARK: - ActiveOrderCard
struct ActiveOrderCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabecera: ID + Estado
            HStack(alignment: .center) {
                Text("ID: \(order.displayId)")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
                Spacer()
                OrderStatusBadgeView(status: order.status)
            }

            Divider()
                .overlay(Color("ColorPrimary").opacity(0.08))

            // Cuerpo: Icono + Info
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "truck.box.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("ColorSecondary"))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 6) {
                    infoRow(title: "Productos:", value: productsSummary)
                    infoRow(title: "Total:", value: order.formattedTotal)
                    infoRow(title: "Fecha de retiro:", value: order.formattedPickupDate)
                    infoRow(title: "Hora de retiro:", value: order.formattedPickupTime)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(Color("ColorPrimary"))
            Text(value)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary").opacity(0.8))
                .lineLimit(2)
        }
    }

    private var productsSummary: String {
        order.items
            .map { $0.nameSnap }
            .joined(separator: ", ")
    }
}
