//
//  QuantitySelectorView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import SwiftUI

struct QuantitySelectorView: View {
    @Binding var quantity: Int
    var minimum: Int = 1
    var maximum: Int = 1000
    @State private var textInput: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 0) {

            // Botón menos
            Button {
                if quantity > minimum {
                    quantity -= 1
                    textInput = "\(quantity)"
                }
            } label: {
                Image(systemName: "minus")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(QuantityButtonStyle())
            .disabled(quantity <= minimum)

            // Campo editable
            TextField("", text: $textInput)
                .font(.title3.bold())
                .foregroundColor(Color("ColorPrimary"))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .frame(width: 70)
                .focused($isFocused)
                .onChange(of: textInput) { value in
                    let filtered = value.filter { $0.isNumber }
                    if filtered != value { textInput = filtered }
                    if let parsed = Int(filtered) {
                        quantity = min(max(parsed, minimum), maximum)
                    }
                }
                .onChange(of: quantity) { value in
                    if !isFocused {
                        textInput = "\(value)"
                    }
                }
                .onSubmit {
                    if let parsed = Int(textInput) {
                        quantity = min(max(parsed, minimum), maximum)
                    } else {
                        quantity = minimum
                    }
                    textInput = "\(quantity)"
                }

            // Botón más
            Button {
                if quantity < maximum {
                    quantity += 1
                    textInput = "\(quantity)"
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(QuantityButtonStyle())
            .disabled(quantity >= maximum)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color("ColorPrimary").opacity(0.08), radius: 4, x: 0, y: 2)
        .onAppear { textInput = "\(quantity)" }
    }
}

struct QuantityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color("ColorPrimary"))
            .background(
                configuration.isPressed
                ? Color("ColorPrimary").opacity(0.1)
                : Color.clear
            )
    }
}
