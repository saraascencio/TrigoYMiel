//
//  OrderStatusBadgeView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 16/4/26.
//
import SwiftUI

struct OrderStatusBadgeView: View {

    let status: OrderStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption.bold())
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var backgroundColor: Color {
        switch status {
        case .pending:        return Color("ColorPrimary").opacity(0.10)
        case .inPreparation:  return Color.blue.opacity(0.12)
        case .readyForPickup: return Color("ColorSecondary").opacity(0.15)
        case .delivered:      return Color.green.opacity(0.12)
        case .cancelled:      return Color.red.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .pending:        return Color("ColorPrimary")
        case .inPreparation:  return Color.blue
        case .readyForPickup: return Color("ColorSecondary")
        case .delivered:      return Color.green
        case .cancelled:      return Color.red
        }
    }
}
