//
// WholesaleLockedView.swift
// TrigoYMiel
//
// Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct WholesaleLockedView: View {
    @ObservedObject var viewModel: WholesaleViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: Título de página
                Text("Mayoreo")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ColorPrimary"))
                    .padding(.top, 56)
                    .padding(.leading, 20)
                
                // MARK: Contenido centrado
                VStack(spacing: 24) {
                    // Pregunta principal
                    Text("¿Deseas que tú evento\nsea inolvidable?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("ColorPrimary"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                    
                    // Beneficios
                    VStack(alignment: .leading, spacing: 6) {
                        bulletItem("Recibe los mejores precios")
                        bulletItem("Encuentra el pan perfecto")
                        Text("Y alegra el día de tus invitados")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorText"))
                            .padding(.leading, 16)
                    }
                    
                    // Párrafo explicativo
                    Text("Cuando tú amigo se registre\nusando tú código de\ninvitación, se activará tú\nacceso a mayoreo.")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorText").opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.top, 8)
                    
                    // Botón naranja
                    Button {
                        Task { await viewModel.fetchReferralCode() }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Invitar a un amigo")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("ColorSecondary"))
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let code = viewModel.referralCode?.code {
                TextShareSheet(items: [
                    "¡Únete a Trigo y Miel con mi código de invitación: \(code) y juntos desbloqueamos acceso a mayoreo."
                ])
            }
        }
        .alert("Error",
               isPresented: Binding(
                   get: { viewModel.errorMessage != nil },
                   set: { if !$0 { viewModel.errorMessage = nil } }
               )) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private func bulletItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14))
                .foregroundColor(Color("ColorText"))
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color("ColorText"))
        }
    }
}

// MARK: - ShareSheet
struct TextShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct WholesaleLockedView_Previews: PreviewProvider {
    static var previews: some View {
        WholesaleLockedView(
            viewModel: WholesaleViewModel(
                userId: "preview",
                userTier: .retail,
                inviteFriendUseCase: InviteFriendUseCase(
                    referralRepository: ReferralRepositoryImpl()
                )
            )
        )
    }
}
