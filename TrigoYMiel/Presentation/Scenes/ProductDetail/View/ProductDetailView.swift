//
//  ProductDetailView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import SwiftUI

struct ProductDetailView: View {

    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(product: Product, currentUser: User, diContainer: AppDIContainer) {
        let cartDI    = diContainer.cartDIContainer
        let orderRepo = diContainer.orderDIContainer.makeOrderRepository()
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(
            product:          product,
            currentUser:      currentUser,
            cartRepository:   cartDI.makeCartRepository(),
            orderRepository:  orderRepo,
            addToCartUseCase: cartDI.makeAddToCartUseCase(),
            promotionDataSource: PromotionFirestoreDataSource()
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Imagen
                AsyncImage(url: URL(string: viewModel.product.imageURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        ZStack {
                            Color("ColorAccent").opacity(0.2)
                            Image(systemName: "photo")
                                .foregroundColor(Color("ColorPrimary").opacity(0.3))
                        }
                    default:
                        ProgressView().tint(Color("ColorPrimary"))
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .frame(height: 300)
                .clipped()

                // MARK: Contenido
                VStack(alignment: .leading, spacing: 20) {

                    // Nombre + precio base
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.product.name)
                                .font(.title2.bold())
                                .foregroundColor(Color("ColorPrimary"))
                            Text(viewModel.product.description)
                                .font(.subheadline)
                                .foregroundColor(Color("ColorPrimary").opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Text(viewModel.product.formattedPrice)
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                    }

                    // Retiro en tienda
                    HStack(spacing: 8) {
                        Image(systemName: "truck.box.fill")
                            .foregroundColor(Color("ColorSecondary"))
                        Text("Retiro en tienda")
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.8))
                    }

                    Divider()

                    // Banner bloqueo
                    if viewModel.isBlockedByOrder {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                            Text(viewModel.blockMessage ?? "")
                                .font(.caption.bold())
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Cantidad
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cantidad")
                            .font(.headline)
                            .foregroundColor(Color("ColorPrimary"))

                        QuantitySelectorView(
                            quantity: $viewModel.quantity,
                            minimum:  1,
                            maximum:  viewModel.isWholesale ? 1000 : 100
                        )
                        .opacity(viewModel.isBlockedByOrder ? 0.5 : 1.0)
                        .disabled(viewModel.isBlockedByOrder)

                        // Hint mayoreo
                        if viewModel.isWholesale {
                            Text("Mínimo 75 uds para pedidos mayoristas")
                                .font(.caption)
                                .foregroundColor(Color("ColorPrimary").opacity(0.45))
                        }
                    }

                    // MARK: Preview descuento mayoreo
                    if viewModel.isWholesale,
                       let promo = viewModel.activePromotion {
                        wholesaleDiscountPreview(promo)
                    }

                    Divider()

                    // Precio total
                    HStack {
                        Text("Precio total:")
                            .font(.headline)
                            .foregroundColor(Color("ColorPrimary"))
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if viewModel.isWholesale,
                               viewModel.activePromotion != nil,
                               viewModel.quantity >= 75 {
                                Text(viewModel.totalPriceFormatted)
                                    .font(.caption)
                                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
                                    .strikethrough()
                                Text(viewModel.discountedTotalFormatted)
                                    .font(.title3.bold())
                                    .foregroundColor(Color("ColorSecondary"))
                            } else {
                                Text(viewModel.totalPriceFormatted)
                                    .font(.title3.bold())
                                    .foregroundColor(Color("ColorPrimary"))
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Volver")
                    }
                    .font(.headline)
                    .foregroundColor(Color("ColorPrimary"))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionButton
        }
        .alert("Atención", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .overlay { successOverlay }
    }

    // MARK: - Preview descuento mayoreo

    private func wholesaleDiscountPreview(_ promo: Promotion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "tag.fill")
                    .foregroundColor(Color("ColorSecondary"))
                Text("Promoción mayorista activa")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
            }

            if viewModel.quantity >= 75 {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Descuento \(promo.formattedDiscount):")
                            .font(.caption)
                            .foregroundColor(Color("ColorPrimary").opacity(0.6))
                        Spacer()
                        Text("- \(viewModel.savingsFormatted)")
                            .font(.caption.bold())
                            .foregroundColor(Color("ColorSecondary"))
                    }
                    HStack {
                        Text("Total con descuento:")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        Spacer()
                        Text(viewModel.discountedTotalFormatted)
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorSecondary"))
                    }
                }
            } else {
                Text("Agrega al menos 75 unidades para aplicar el \(promo.formattedDiscount) de descuento.")
                    .font(.caption)
                    .foregroundColor(Color("ColorPrimary").opacity(0.55))
            }
        }
        .padding(14)
        .background(Color("ColorAccent").opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Botón añadir

    private var bottomActionButton: some View {
        Button {
            viewModel.addToCart()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
        } label: {
            VStack(spacing: 4) {
                if viewModel.isAddingToCart {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Text(
                            viewModel.isBlockedByOrder
                            ? (viewModel.blockMessage ?? "No disponible")
                            : "Añadir al carrito"
                        )
                        .multilineTextAlignment(.center)
                        if !viewModel.isBlockedByOrder {
                            Spacer()
                            // Muestra precio con descuento si aplica
                            if viewModel.isWholesale,
                               viewModel.activePromotion != nil,
                               viewModel.quantity >= 75 {
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text(viewModel.totalPriceFormatted)
                                        .font(.caption)
                                        .strikethrough()
                                        .opacity(0.7)
                                    Text(viewModel.discountedTotalFormatted)
                                        .font(.subheadline.bold())
                                }
                            } else {
                                Text(viewModel.totalPriceFormatted)
                            }
                        }
                    }
                }
            }
            .font(.headline.bold())
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(
                viewModel.isBlockedByOrder ? Color.gray.opacity(0.7) :
                viewModel.canAddToCart     ? Color("ColorSecondary") :
                Color.gray.opacity(0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .disabled(viewModel.isBlockedByOrder || !viewModel.canAddToCart || viewModel.isAddingToCart)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }

    // MARK: - Overlay éxito

    private var successOverlay: some View {
        Group {
            if viewModel.showSuccessMessage {
                Text("✓ Añadido al carrito")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.green.opacity(0.95))
                    .clipShape(Capsule())
                    .shadow(radius: 8)
                    .padding(.bottom, 120)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .opacity
                    ))
            }
        }
        .animation(.spring(), value: viewModel.showSuccessMessage)
    }
}
