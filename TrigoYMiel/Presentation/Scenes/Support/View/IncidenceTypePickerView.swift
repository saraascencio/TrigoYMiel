//
// IncidenceTypePickerView.swift
// TrigoYMiel
//
// Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

// MARK: - IncidenceTypePickerView
// Chips 100% fieles al prototipo (Frame 17/18)
// - Capsule() para esquinas redondeadas perfectas
// - Centrados automáticamente

struct IncidenceTypePickerView: View {
    @Binding var selectedType: IncidenceType
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(IncidenceType.allCases, id: \.self) { type in
                chipButton(for: type)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func chipButton(for type: IncidenceType) -> some View {
        let isSelected = selectedType == type
        return Button {
            selectedType = type
        } label: {
            Text(type.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : Color("ColorPrimary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("ColorPrimary") : Color.clear)
                )
                .overlay(
                    Capsule()
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
