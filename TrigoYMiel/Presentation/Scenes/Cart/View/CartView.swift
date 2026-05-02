//
//  CartView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct CartView: View {

    @StateObject var viewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss

    let onLogout: () -> Void
    let onSupport: () -> Void
    let onProfile: () -> Void
    
    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: HEADER
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                    }

                    Text("Catálogo")
                        .font(.title3.bold())
                        .foregroundColor(Color("ColorPrimary"))
                        .padding(.leading, 4)

                    Spacer()

                    ProfileMenuButton(
                        onLogout: { onLogout() },
                        onSupport: { onSupport() },
                        onProfile:    { onProfile() },
                        supportLabel: "Soporte"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: CONTENT
                if viewModel.isLoading {

                    Spacer()
                    ProgressView().tint(Color("ColorSecondary"))
                    Spacer()

                } else if viewModel.isEmpty {

                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 56))
                            .foregroundColor(Color("ColorPrimary").opacity(0.2))

                        Text("Tu carrito está vacío")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary").opacity(0.4))

                        Text("Agrega productos desde el catálogo")
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.3))
                    }
                    Spacer()

                } else {

                    ScrollView {

                        VStack(alignment: .leading, spacing: 16) {

                            Text("Mi carrito")
                                .font(.title2.bold())
                                .foregroundColor(Color("ColorPrimary"))
                                .padding(.horizontal, 20)
                                .padding(.top, 4)

                            // MARK: ITEMS
                        
                            VStack(spacing: 12) {
                                ForEach(viewModel.cartItems) { item in
                                   
                                    let promo = (viewModel.totalUnits >= 75) ? viewModel.activePromotion(for: item.product) : nil
                                    
                                    CartItemRowView(
                                        item: item,
                                        promotion: promo,
                                        onRemove: {
                                            Task { await viewModel.removeItem(item) }
                                        },
                                        onQuantityChange: { newQty in
                                            Task {
                                                await viewModel.updateQuantity(item, newQuantity: newQty)
                                            }
                                        }
                                    )
                                }
                            }.padding(.horizontal, 20)

                          
                            .onChange(of: viewModel.cartItems) { _ in
                                viewModel.syncPickupDate()
                            }

                            // MARK: RESUMEN
                            pricesSummary

                            // MARK: PICKUP SELECTOR
                           
                            PickupTimeSelectorView(
                                pickupDate: $viewModel.pickupDate,
                                isWholesaleValid: viewModel.isWholesaleCustomer,
                                totalUnits: viewModel.totalUnits,
                                minDate: viewModel.minPickupDate
                            )
                            .padding(.horizontal, 20)

                            // MARK: BOTÓN
                            Button {
                            
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                to: nil, from: nil, for: nil)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    Task { await viewModel.placeOrder() }
                                }
                            } label: {
                                Group {
                                    if viewModel.isPlacing {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Confirmar pedido")
                                            .font(.headline.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("ColorPrimary"))
                            )
                            .padding(.horizontal, 20)
                            .disabled(viewModel.isPlacing)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await viewModel.loadCart() }

        // MARK: ERROR ALERT
        .alert("Aviso de compra", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Entendido", role: .cancel) {}
        } message: {
            // Aplicamos la limpieza directamente aquí o en el ViewModel
            Text((viewModel.errorMessage ?? "")
                .replacingOccurrences(of: "Unknown error: ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "unknown", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        
        // MARK: SUCCESS ALERT
        .alert("¡Pedido confirmado!", isPresented: $viewModel.orderPlaced) {
            Button("Ver mis pedidos", role: .cancel) { dismiss() }
        } message: {
            Text("Tu pedido fue enviado correctamente.")
        }
    }

    // MARK: - RESUMEN PRECIOS
    private var pricesSummary: some View {
        VStack(spacing: 10) {

            HStack {
                Text("Subtotal")
                    .font(.subheadline)
                    .foregroundColor(Color("ColorPrimary").opacity(0.6))

                Spacer()

                Text(String(format: "$%.2f", viewModel.totalBeforeDiscount))
                    .font(.subheadline)
                    .foregroundColor(Color("ColorPrimary"))
            }

            if viewModel.totalDiscount > 0 {
                HStack {
                    Text("Descuento")
                        .font(.subheadline)
                        .foregroundColor(Color("ColorSecondary"))

                    Spacer()

                    Text("- \(String(format: "$%.2f", viewModel.totalDiscount))")
                        .font(.subheadline.bold())
                        .foregroundColor(Color("ColorSecondary"))
                }
            }

            Divider()
                .overlay(Color("ColorPrimary").opacity(0.10))

            HStack {
                Text("Total")
                    .font(.headline.bold())
                    .foregroundColor(Color("ColorPrimary"))

                Spacer()

                Text(viewModel.formattedTotal)
                    .font(.title3.bold())
                    .foregroundColor(Color("ColorPrimary"))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

