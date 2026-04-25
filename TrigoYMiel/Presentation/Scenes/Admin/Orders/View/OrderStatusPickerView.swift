//
//  OrderStatusPickerView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

// MARK: - OrderStatusPickerView
// Muestra el timeline visual de estados del pedido.
// Reutilizable desde AdminOrderDetailView.

struct OrderStatusPickerView: View {

    let currentStatus: OrderStatus

    var body: some View {
        VStack(spacing: 0) {
            ForEach(OrderStatus.allCases.filter { $0 != .cancelled }, id: \.self) { status in
                OrderStatusRow(
                    status:        status,
                    currentStatus: currentStatus
                )
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - OrderStatusRow

struct OrderStatusRow: View {

    let status:        OrderStatus
    let currentStatus: OrderStatus

    private var state: RowState {
        if currentStatus == .cancelled { return .upcoming }

        let allCases = OrderStatus.allCases.filter { $0 != .cancelled }
        guard
            let currentIndex = allCases.firstIndex(of: currentStatus),
            let statusIndex  = allCases.firstIndex(of: status)
        else { return .upcoming }

        if statusIndex < currentIndex  { return .completed }
        if statusIndex == currentIndex { return .active }
        return .upcoming
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 32, height: 32)
                Image(systemName: iconName)
                    .font(.caption.bold())
                    .foregroundColor(iconForeground)
            }

            Text(status.displayName)
                .font(.subheadline)
                .foregroundColor(
                    state == .upcoming
                    ? Color("ColorPrimary").opacity(0.4)
                    : Color("ColorPrimary")
                )

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            state == .active
            ? Color("ColorSecondary").opacity(0.15)
            : Color.clear
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private enum RowState { case completed, active, upcoming }

    private var iconName: String {
        switch state {
        case .completed: return "checkmark"
        case .active:    return "clock.fill"
        case .upcoming:  return "circle"
        }
    }

    private var iconBackground: Color {
        switch state {
        case .completed: return Color("ColorPrimary")
        case .active:    return Color("ColorSecondary")
        case .upcoming:  return Color("ColorPrimary").opacity(0.12)
        }
    }

    private var iconForeground: Color {
        switch state {
        case .completed, .active: return .white
        case .upcoming:           return Color("ColorPrimary").opacity(0.3)
        }
    }
}
