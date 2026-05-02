//
//  ProfileMenuButton.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 11/4/26.
//
import SwiftUI

struct ProfileMenuButton: View {

    let onLogout:    () -> Void
    let onSupport:   () -> Void
    let onProfile:   () -> Void          
    let supportLabel: String

    init(
        onLogout:     @escaping () -> Void,
        onSupport:    @escaping () -> Void,
        onProfile:    @escaping () -> Void = {},
        supportLabel: String = "Accede a soporte"
    ) {
        self.onLogout     = onLogout
        self.onSupport    = onSupport
        self.onProfile    = onProfile
        self.supportLabel = supportLabel
    }

    var body: some View {
        Menu {
            // Mi perfil — primera opción
            Button {
                onProfile()
            } label: {
                Label("Mi perfil", systemImage: "person.crop.circle")
            }

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
