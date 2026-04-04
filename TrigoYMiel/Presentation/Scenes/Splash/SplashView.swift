//
//  SplashView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct SplashView: View {

    // MARK: - Animation states
    @State private var logoScale:   CGFloat = 0.6
    @State private var logoOpacity: Double  = 0.0
    @State private var logoOffset:  CGFloat = 30
    @State private var bgOpacity:   Double  = 0.0
    @State private var finished:    Bool    = false

    var body: some View {
        ZStack {
            // MARK: Fondo
            Color("ColorBackground")
                .ignoresSafeArea()
                .opacity(bgOpacity)

            // MARK: Logo
            VStack(spacing: 12) {
                Image("LogoTrigoYMiel")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: logoOffset)

            }
        }
        .onAppear { runAnimation() }
    }

    // MARK: - Secuencia de animación
    private func runAnimation() {

        // 1. Fondo aparece
        withAnimation(.easeIn(duration: 0.3)) {
            bgOpacity = 1.0
        }

        // 2. Logo sube y aparece
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            logoScale   = 1.0
            logoOpacity = 1.0
            logoOffset  = 0
        }

        // 3. Logo rebota levemente
        withAnimation(.easeInOut(duration: 0.3).delay(1.0)) {
            logoScale = 1.08
        }
        withAnimation(.easeInOut(duration: 0.3).delay(1.3)) {
            logoScale = 1.0
        }

        // 4. Logo se desvanece y termina el splash
        withAnimation(.easeOut(duration: 0.4).delay(1.8)) {
            logoOpacity = 0.0
            bgOpacity   = 0.0
        }
    }
}
