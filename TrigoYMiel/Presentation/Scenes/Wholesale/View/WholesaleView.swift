//
// WholesaleView.swift
// TrigoYMiel
//
// Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct WholesaleView: View {

    @StateObject var viewModel: WholesaleViewModel
    let onLogout:        () -> Void
    let onSupport:       () -> Void
    let onWholesaleCart: () -> Void

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Spacer()
                    ProfileMenuButton(
                        onLogout:     { onLogout() },
                        onSupport:    { onSupport() },
                        supportLabel: "Soporte"
                    )
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // MARK: Subvista según tier
                switch viewModel.currentTier {
                case .wholesale:
                    WholesaleActiveView(
                        viewModel: viewModel,
                        onCartTap: onWholesaleCart
                    )
                case .retail:
                    WholesaleLockedView(viewModel: viewModel)
                }
            }
        }
        .task { await viewModel.onAppear() }
    }
}
