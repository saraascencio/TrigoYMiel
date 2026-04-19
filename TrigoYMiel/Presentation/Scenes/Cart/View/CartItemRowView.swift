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
                        let newQty = max(1, item.quantity - 1)
                        quantityInput = "\(newQty)"
                        onQuantityChange(newQty)
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
                        let newQty = item.quantity + 1
                        quantityInput = "\(newQty)"
                        onQuantityChange(newQty)
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
        let parsed = Int(quantityInput) ?? 1
        let clamped = max(1, min(parsed, 1000))
        quantityInput = "\(clamped)"
        onQuantityChange(clamped)
    }

    private func discountedSubtotal(_ promo: Promotion) -> String {
        let discounted = item.subtotal * (1 - promo.discountPercentage / 100)
        return String(format: "$%.2f", discounted)
    }
}
