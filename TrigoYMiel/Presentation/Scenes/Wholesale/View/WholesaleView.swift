//
// WholesaleView.swift
// TrigoYMiel
//
// Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

// MARK: - WholesaleView
// Vista raíz del Tab "Mayoreo".
// Ahora con NavigationStack (como principal) + toolbar con los íconos.
// Las subvistas (Locked / Active) ya no tienen ZStack ni duplican los íconos.
struct WholesaleView: View {
    @StateObject var viewModel: WholesaleViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.userTier {
                case .wholesale:
                    WholesaleActiveView(viewModel: viewModel)
                case .retail:
                    WholesaleLockedView(viewModel: viewModel)
                }
            }
            .navigationTitle("")                    // Sin título en la barra (el título grande está dentro del contenido)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Menú de perfil
                        Menu {
                            Button {
                                // Acción: cerrar sesión
                            } label: {
                                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                            Button {
                                // Acción: contacta a soporte
                            } label: {
                                Label("Contacta a soporte", systemImage: "message")
                            }
                        } label: {
                            Image(systemName: "person.circle")
                                .font(.system(size: 22))
                                .foregroundColor(Color("ColorPrimary"))
                        }
                        
                        // Carrito
                        Button {
                            // Navegar al carrito (coordinator)
                        } label: {
                            Image(systemName: "cart")
                                .font(.system(size: 22))
                                .foregroundColor(Color("ColorPrimary"))
                        }
                    }
                }
            }
            // Fondo transparente en la barra para que se vea exactamente como el prototipo
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task { await viewModel.onAppear() }
    }
}

// MARK: - Preview
struct WholesaleView_Previews: PreviewProvider {
    static var previews: some View {
        WholesaleView(
            viewModel: WholesaleViewModel(
                userId: "preview",
                userTier: .retail,
                inviteFriendUseCase: InviteFriendUseCase(
                    referralRepository: ReferralRepositoryImpl()
                )
            )
        )
        .previewDisplayName("Bloqueado")
        
        WholesaleView(
            viewModel: WholesaleViewModel(
                userId: "preview",
                userTier: .wholesale,
                inviteFriendUseCase: InviteFriendUseCase(
                    referralRepository: ReferralRepositoryImpl()
                )
            )
        )
        .previewDisplayName("Activo")
    }
}
