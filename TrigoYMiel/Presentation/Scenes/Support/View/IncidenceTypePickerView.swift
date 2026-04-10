//
//  IncidenceTypePickerView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import SwiftUI

// MARK: - IncidenceTypePickerView
// Fila de chips seleccionables para elegir el tipo de incidencia.
// Pedido incompleto | Alérgeno | Consulta
// El chip seleccionado se muestra con fondo ColorPrimary y texto blanco.
// Los no seleccionados muestran borde y texto ColorPrimary.

struct IncidenceTypePickerView: View {

    @Binding var selectedType: IncidenceType

    var body: some View {
        HStack(spacing: 8) {
            ForEach(IncidenceType.allCases, id: \.self) { type in
                chipButton(for: type)
            }
        }
    }

    // MARK: - Chip individual
    private func chipButton(for type: IncidenceType) -> some View {
        let isSelected = selectedType == type

        return Button {
            selectedType = type
        } label: {
            Text(type.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : Color("ColorPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color("ColorPrimary") : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("ColorPrimary"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct IncidenceTypePickerView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selected: IncidenceType = .incompleteOrder
        var body: some View {
            IncidenceTypePickerView(selectedType: $selected)
                .padding()
                .background(Color("ColorBackground"))
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
