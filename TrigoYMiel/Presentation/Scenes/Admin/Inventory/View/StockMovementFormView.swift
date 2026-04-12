//
//  StockMovementFormView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

// MARK: - Motivos predefinidos
enum MovementReason: String, CaseIterable {
    case production   = "Producción del día"
    case supplier     = "Compra a proveedor"
    case adjustment   = "Ajuste de inventario"
    case expiration   = "Producto vencido"
    case loss         = "Merma"
    case other        = "Otro"
}

struct StockMovementFormView: View {

    let entry:        InventoryEntry
    let isSubmitting: Bool
    let onConfirm:    (MovementType, Int, String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedType:   MovementType   = .entry
    @State private var quantityText:   String         = ""
    @State private var selectedReason: MovementReason = .production
    
 
    @State private var hasInteracted: Bool = false
    
    // MARK: - Validación de Lógica
    
    private var quantityError: String? {
        // Solo mostramos error si el usuario ya escribió algo o intentó borrar
        guard hasInteracted else { return nil }
        
        if quantityText.isEmpty {
            return "La cantidad es obligatoria"
        }
        if let value = Int(quantityText), value <= 0 {
            return "La cantidad debe ser mayor a 0"
        }
        return nil
    }

    private var isFormValid: Bool {
        if let value = Int(quantityText), value > 0 {
            return true
        }
        return false
    }

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: Header con flecha (Café)
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(Color("ColorPrimary"))
                        }
                        
                        Text("Registrar movimiento")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.bottom, 4)

                    // MARK: Stock actual
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stock actual")
                            .font(.headline.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        Text(entry.productName)
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.7))

                        Text("\(entry.currentStock) unidades")
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // MARK: Tipo de movimiento
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tipo de movimiento")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        HStack(spacing: 12) {
                            Button { selectedType = .entry } label: {
                                labelForType(title: "Entrada", icon: "plus.circle", isSelected: selectedType == .entry)
                            }

                            Button { selectedType = .exit } label: {
                                labelForType(title: "Salida", icon: "minus.circle", isSelected: selectedType == .exit, activeColor: Color("ColorPrimary"))
                            }
                        }
                    }

                    // MARK: Cantidad (Validación inteligente)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Cantidad")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        
                        TextField("0", text: $quantityText)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(quantityError != nil ? Color.red.opacity(0.6) : Color("ColorPrimary").opacity(0.20), lineWidth: 1)
                            )
                            .onChange(of: quantityText) { newValue in
                             
                                if !hasInteracted { hasInteracted = true }
                                
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.quantityText = filtered
                                }
                            }
                        
                        if let error = quantityError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 2)
                        }
                    }

                    // MARK: Motivo
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Motivo")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        Menu {
                            ForEach(MovementReason.allCases, id: \.self) { reason in
                                Button(reason.rawValue) { selectedReason = reason }
                            }
                        } label: {
                            HStack {
                                Text(selectedReason.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(Color("ColorPrimary"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(Color("ColorPrimary").opacity(0.5))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("ColorPrimary").opacity(0.20), lineWidth: 1)
                            )
                        }
                    }

                    // MARK: Botón de registro
                    Button {
                        if let quantity = Int(quantityText) {
                            onConfirm(selectedType, quantity, selectedReason.rawValue)
                        }
                    } label: {
                        Group {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Registrar movimiento")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isFormValid && !isSubmitting ? Color("ColorSecondary") : Color.gray.opacity(0.4))
                    )
                    .disabled(!isFormValid || isSubmitting)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
    }

    // Helper para los botones de tipo
    @ViewBuilder
    private func labelForType(title: String, icon: String, isSelected: Bool, activeColor: Color = Color("ColorSecondary")) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.bold())
            Text(title)
                .font(.subheadline.bold())
        }
        .foregroundColor(isSelected ? .white : Color("ColorPrimary"))
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(isSelected ? activeColor : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.clear : Color("ColorPrimary").opacity(0.2), lineWidth: 1)
        )
    }
}
