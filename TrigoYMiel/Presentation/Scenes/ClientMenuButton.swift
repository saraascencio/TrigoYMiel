//
//  ClientMenuButton.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 18/4/26.
//
import SwiftUI

struct ClientMenuButton: View {

    let onLogout:   () -> Void
    let onSupport:  () -> Void
    let onCartTap:  () -> Void
    let onProfile:  () -> Void
    let supportLabel: String

    init(
        onLogout:     @escaping () -> Void,
        onSupport:    @escaping () -> Void,
        onCartTap:    @escaping () -> Void,
        onProfile:    @escaping () -> Void = {},
        supportLabel: String = "Soporte"
    ) {
        self.onLogout     = onLogout
        self.onSupport    = onSupport
        self.onCartTap    = onCartTap
        self.onProfile    = onProfile
        self.supportLabel = supportLabel
    }

    var body: some View {
        HStack(spacing: 16) {
            Spacer()

            ProfileMenuButton(
                onLogout:     onLogout,
                onSupport:    onSupport,
                onProfile:    onProfile,
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
