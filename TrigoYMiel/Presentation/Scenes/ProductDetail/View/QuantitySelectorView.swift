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
            // MARK: Botón Menos
            Button {
                let newQuantity = max(minimum, quantity - 1)
                if newQuantity != quantity {
                    quantity = newQuantity
                    textInput = "\(newQuantity)"
                }
            } label: {
                Image(systemName: "minus")
                    .font(.title2.bold())
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(QuantityButtonStyle())
            .disabled(quantity <= minimum)
            
            // MARK: Campo editable
            TextField("", text: $textInput)
                .font(.title3.bold())
                .foregroundColor(Color("ColorPrimary"))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .frame(width: 70)
                .focused($isFocused)
                .onChange(of: textInput) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        textInput = filtered
                    }
                    
                    if let parsed = Int(filtered), parsed != quantity {
                        quantity = min(max(parsed, minimum), maximum)
                    }
                }
                .onChange(of: quantity) { newValue in
                    if !isFocused {
                        textInput = "\(newValue)"
                    }
                }
                .onSubmit {
                    commitInput()
                }
                .onChange(of: isFocused) { isFocusedNow in
                    if !isFocusedNow {
                        commitInput()
                    }
                }
            
            // MARK: Botón Más
            Button {
                let newQuantity = min(maximum, quantity + 1)
                if newQuantity != quantity {
                    quantity = newQuantity
                    textInput = "\(newQuantity)"
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(QuantityButtonStyle())
            .disabled(quantity >= maximum)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color("ColorPrimary").opacity(0.08), radius: 4, x: 0, y: 2)
        .onAppear {
            textInput = "\(quantity)"
        }
    }
    
    private func commitInput() {
        let parsed = Int(textInput) ?? minimum
        let clamped = min(max(parsed, minimum), maximum)
        
        if clamped != quantity {
            quantity = clamped
        }
        textInput = "\(quantity)"
    }
}

struct QuantityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color("ColorPrimary"))
            .background(configuration.isPressed ? Color("ColorPrimary").opacity(0.15) : Color.clear)
    }
}

