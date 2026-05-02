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
    @FocusState private var isInputFocused: Bool
    
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
                                            minimum:  viewModel.isWholesale ? 75 : 1,
                                            maximum:  min(viewModel.isWholesale ? 100 : 74, viewModel.product.stock)
                                        )
                                        .focused($isInputFocused) // 2. VINCULA EL FOCO
                                        .onChange(of: isInputFocused) { isFocused in
                                            if !isFocused {
                                                viewModel.commitQuantity() // 3. VALIDA AL SALIR
                                        }
                        }
                        .opacity(viewModel.isBlockedByOrder ? 0.5 : 1.0)
                        .disabled(viewModel.isBlockedByOrder)

                        // Mensajes informativos de stock y límites[cite: 1]
                        Group {
                            if viewModel.product.stock <= 0 {
                                Text("Producto agotado temporalmente")
                                    .foregroundColor(.red)
                            } else if viewModel.product.stock < (viewModel.isWholesale ? 75 : 1) {
                                Text("Stock insuficiente para tu tipo de cliente")
                                    .foregroundColor(.orange)
                            } else if viewModel.isWholesale {
                                Text("Límite mayorista: 75-100 unidades (Máximo 1000 en total)")
                            } else {
                                Text("Límite minorista: máximo 74 unidades")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(Color("ColorPrimary").opacity(0.45))
                    }
                    
                    // MARK: Preview descuento mayoreo
                    if let promo = viewModel.activePromotion {
                        promotionDiscountPreview(promo)
                    }
                    
                    Divider()

                    // Precio total
                    // Precio total
                    HStack {
                        Text("Precio total:")
                            .font(.headline)
                            .foregroundColor(Color("ColorPrimary"))
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            // Nueva lógica: Si hay promo y se cumplen sus condiciones (appliesNow)
                            if let promo = viewModel.activePromotion,
                               (!promo.wholesaleOnly || viewModel.quantity >= 75) {
                                
                                Text(viewModel.totalPriceFormatted)
                                    .font(.caption)
                                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
                                    .strikethrough()
                                
                                Text(viewModel.discountedTotalFormatted)
                                    .font(.title3.bold())
                                    .foregroundColor(Color("ColorSecondary"))
                            } else {
                                // Precio normal si no hay promo activa
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

    private func promotionDiscountPreview(_ promo: Promotion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Encabezado dinámico: Si no es exclusiva, no asustamos al minorista con la palabra "Mayorista"
            HStack(spacing: 8) {
                Image(systemName: "tag.fill")
                    .foregroundColor(Color("ColorSecondary"))
                Text(promo.wholesaleOnly ? "Promoción mayorista activa" : "Promoción especial activa")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
            }

            // ¿Se aplica el descuento en este momento?
            // Se aplica si la promo es para todos O si el usuario ya alcanzó las 75 unidades
            let appliesNow = !promo.wholesaleOnly || viewModel.quantity >= 75

            if appliesNow {
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
                // Este mensaje solo saldrá si la promo requiere 75 unidades y el usuario tiene menos
                Text("Agrega al menos 75 unidades para aplicar el \(promo.formattedDiscount) de descuento.")
                    .font(.caption)
                    .foregroundColor(Color("ColorPrimary").opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color("ColorAccent").opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Botón añadir

    private var bottomActionButton: some View {
        Button {
                // 1. Forzamos el cierre del teclado
                // Esto dispara automáticamente el 'commitQuantity' a través del .onChange(of: isFocused)
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
                
                // 2. Pequeño delay para asegurar que quantityInput se procesó y validó
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                        viewModel.addToCart()
                        
                        // 3. Si no hubo error, cerramos la vista después del feedback
                        if viewModel.errorMessage == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                dismiss()
                            }
                        }
                    
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
                            
                            // Cambiamos la condición para que no dependa solo de isWholesale
                            if let promo = viewModel.activePromotion,
                               (!promo.wholesaleOnly || viewModel.quantity >= 75) {
                                
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


