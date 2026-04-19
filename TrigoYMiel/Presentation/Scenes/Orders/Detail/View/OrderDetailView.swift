//
//  OrderDetailView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct OrderDetailView: View {
    @StateObject var viewModel: OrderDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    init(order: Order, updateOrderStatusUseCase: UpdateOrderStatusUseCase) {
        _viewModel = StateObject(wrappedValue: OrderDetailViewModel(
            order: order,
            updateOrderStatusUseCase: updateOrderStatusUseCase
        ))
    }
    
    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Detalle de pedido")
                            .font(.title.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .padding(.horizontal, 20)
                        
                        // Card Principal
                        VStack(alignment: .leading, spacing: 20) {
                            Text("ID: \(viewModel.order.displayId)")
                                .font(.title3.bold())
                                .foregroundColor(Color("ColorPrimary"))
                                .padding(.bottom, 8)
                            
                            ForEach(viewModel.order.items) { item in
                                productRow(item)
                                if item.id != viewModel.order.items.last?.id {
                                    Divider().opacity(0.5)
                                }
                            }
                            
                            // Footer: Botón Cancelar y Total
                            HStack(alignment: .bottom) {
                                if viewModel.order.status == .pending {
                                    cancelButton
                                }
                                
                                Spacer()
                                
                                totalSection
                            }

                            .padding(.top,14)
                        }
                        .padding(24)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("¿Confirmar cancelación?", isPresented: $viewModel.showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Sí, cancelar", role: .destructive) {
                Task { await viewModel.cancelOrder() }
            }
        } message: {
            Text("Si cancelas ahora, la panadería no procesará tu orden.")
        }
    }
    
    // MARK: - Componentes de UI Extraídos
    
    private var cancelButton: some View {
        Button {
            viewModel.showCancelAlert = true
        } label: {
            HStack(spacing: 6) {
                if viewModel.isLoading {
                    ProgressView().tint(.red)
                } else {
                    Image(systemName: "xmark.circle")
                    Text("Cancelar pedido")
                }
            }
            .font(.subheadline.bold())
            .foregroundColor(.red)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.red.opacity(0.08))
            .cornerRadius(10)
        }
        .disabled(viewModel.isLoading)
    }
    
    private var totalSection: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("TOTAL")
                .font(.caption2.bold())
                .foregroundColor(.secondary)
            Text(viewModel.formatCurrency(viewModel.order.total))
                .font(.title2.bold())
                .foregroundColor(Color("ColorPrimary"))
        }
    }
    
    private func statusLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.subheadline.bold())
            .foregroundColor(color)
            .padding(10)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }


    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                    Text("En curso")
                }
                .font(.headline)
                .foregroundColor(Color("ColorPrimary"))
            }
            Spacer()
            Image(systemName: "cart")
                .font(.title2)
                .foregroundColor(Color("ColorPrimary"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private func productRow(_ item: OrderItem) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.nameSnap)
                    .font(.headline)
                    .foregroundColor(Color("ColorPrimary"))
                Text("Unidades: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Subtotal: \(viewModel.calculateSubtotal(price: item.unitPriceSnap, quantity: item.quantity))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let url = URL(string: item.imageURLSnap), !item.imageURLSnap.isEmpty {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { ProgressView() }
                .frame(width: 100, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 80)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }
        }
        .padding(.vertical, 4)
    }
}
