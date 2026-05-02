//
//  CartItemRowView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct CartItemRowView: View {

    let item:         CartItem
    let promotion:    Promotion?
    let onRemove:     () -> Void
    let onQuantityChange: (Int) -> Void

    @State private var quantityInput: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {

            // MARK: Imagen
            AsyncImage(url: URL(string: item.product.imageURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .failure:         Color("ColorAccent").opacity(0.3)
                default:
                    Color("ColorAccent").opacity(0.2)
                        .overlay(ProgressView().scaleEffect(0.7))
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // MARK: Info
            VStack(alignment: .leading, spacing: 6) {

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.product.name)
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        if let promo = promotion {
                            Text("\(promo.formattedDiscount) descuento")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color("ColorSecondary"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    Spacer()
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.4))
                    }
                }

                // Precio con o sin descuento
                if let promo = promotion {
                    HStack(spacing: 6) {
                        Text(item.formattedSubtotal)
                            .font(.caption)
                            .foregroundColor(Color("ColorPrimary").opacity(0.4))
                            .strikethrough()
                        Text(discountedSubtotal(promo))
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorSecondary"))
                    }
                } else {
                    Text(item.formattedSubtotal)
                        .font(.subheadline)
                        .foregroundColor(Color("ColorPrimary").opacity(0.8))
                }

                // MARK: Selector cantidad con input manual
                HStack(spacing: 0) {
                    Button {
                        let minAllowed = (item.quantity >= 75) ? 75 : 1
                        let newQty = max(minAllowed, item.quantity - 1)
                        if newQty != item.quantity {
                            quantityInput = "\(newQty)"
                            onQuantityChange(newQty)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .frame(width: 36, height: 36)
                            .background(Color("ColorPrimary").opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    TextField("", text: $quantityInput)
                        .font(.subheadline.bold())
                        .foregroundColor(Color("ColorPrimary"))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .frame(width: 44)
                        .focused($isFocused)
                        .onChange(of: quantityInput) { value in
                            let filtered = value.filter { $0.isNumber }
                            if filtered != value { quantityInput = filtered }
                        }
                        .onSubmit {
                            commitInput()
                        }
                        .onChange(of: isFocused) { focused in
                            if !focused { commitInput() }
                        }

                    Button {
                        let maxAllowed = (item.quantity >= 75) ? 100 : 74
                        let finalMax = min(maxAllowed, item.product.stock) // No superar stock
                        let newQty = min(finalMax, item.quantity + 1)
                        
                        if newQty != item.quantity {
                            quantityInput = "\(newQty)"
                            onQuantityChange(newQty)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .frame(width: 36, height: 36)
                            .background(Color("ColorPrimary").opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
        .onAppear { quantityInput = "\(item.quantity)" }
        .onChange(of: item.quantity) { value in
            if !isFocused { quantityInput = "\(value)" }
        }
    }

    private func commitInput() {
        // Si el campo está vacío o es 0, parsed será 1 por defecto
        let parsed = Int(quantityInput) ?? 1
        
        let isWholesale = item.quantity >= 75
        let minAllowed = isWholesale ? 75 : 1
        let maxAllowed = isWholesale ? 100 : 74
        let finalMax = min(maxAllowed, item.product.stock)
        
        // Aquí el clamped asegura que el 0 se convierta en 1 automáticamente
        let clamped = max(minAllowed, min(parsed, finalMax))
        
        quantityInput = "\(clamped)"
        
        if clamped != item.quantity {
            onQuantityChange(clamped)
        }
    }
    
    private func discountedSubtotal(_ promo: Promotion) -> String {
        let discounted = item.subtotal * (1 - promo.discountPercentage / 100)
        return String(format: "$%.2f", discounted)
    }
}
