//
//  ProfileMenuButton.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 11/4/26.
//
import SwiftUI

struct ProfileMenuButton: View {

    let onLogout:  () -> Void
    let onSupport: () -> Void
    let supportLabel: String  // ← personalizable por rol

    init(
        onLogout:     @escaping () -> Void,
        onSupport:    @escaping () -> Void,
        supportLabel: String = "Accede a soporte"
    ) {
        self.onLogout     = onLogout
        self.onSupport    = onSupport
        self.supportLabel = supportLabel
    }

    var body: some View {
        Menu {
            Button {
                onSupport()
            } label: {
                Label(supportLabel, systemImage: "exclamationmark.bubble")
            }

            Button(role: .destructive) {
                onLogout()
            } label: {
                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Image(systemName: "person.circle")
                .resizable()
                   .frame(width: 28, height: 28)
                   .foregroundColor(Color("ColorPrimary"))
        }
    }
}
