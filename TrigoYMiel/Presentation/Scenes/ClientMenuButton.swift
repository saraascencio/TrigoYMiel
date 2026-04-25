//
//  ClientMenuButton.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 18/4/26.
//

import SwiftUI
struct ClientMenuButton: View {
    let onLogout: () -> Void
    let onSupport: () -> Void
    let onCartTap: () -> Void
    let supportLabel: String = "Soporte"

    var body: some View {
        HStack(spacing: 16) {
            Spacer()
            
            ProfileMenuButton(
                onLogout: onLogout,
                onSupport: onSupport,
                supportLabel: supportLabel
            )
            
            Button(action: onCartTap) {
                Image(systemName: "cart")
                    .font(.title2)
                    .foregroundColor(Color("ColorPrimary"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}
