//
//  OrderHistoryView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct OrderHistoryView: View {

    @StateObject var viewModel: OrderHistoryViewModel
    let onLogout:  () -> Void
    let onSupport: () -> Void
    let onCartTap: () -> Void
    let onProfile: () -> Void
    
    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
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

                // MARK: Título
                Text("Historial de pedidos")
                    .font(.title.bold())
                    .foregroundColor(Color("ColorPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // MARK: Contenido
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(Color("ColorSecondary"))
                    Spacer()

                } else if viewModel.orders.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 52))
                            .foregroundColor(Color("ColorPrimary").opacity(0.2))
                        Text("Sin historial aún")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary").opacity(0.4))
                        Text("Tus pedidos entregados aparecerán aquí")
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()

                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.orders) { order in
                                OrderHistoryCard(order: order)
                            }
                        }
                
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .task { await viewModel.loadHistory() }
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

// MARK: - OrderHistoryCard
struct OrderHistoryCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: Fecha arriba (igual que antes)
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                Text(order.createdAt.formatted(
                    .dateTime.day().month(.wide).year().locale(Locale(identifier: "es_ES"))
                ))
            }
            .font(.caption.bold())
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
            
            // MARK: Card con formato similar a ActiveOrderCard
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
                
                // Cuerpo: Icono + Información
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: "truck.box.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color("ColorSecondary"))
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(title: "Productos:", value: productsSummary)
                        infoRow(title: "Total:", value: order.formattedTotal)
                        infoRow(title: "Hora de retiro:", value: order.formattedPickupTime)
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Componente reutilizable para cada fila
    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(Color("ColorPrimary"))
                .frame(width: 110, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary").opacity(0.85))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var productsSummary: String {
        order.items.map(\.nameSnap).joined(separator: ", ")
    }
}
