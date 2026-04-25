//
//  IncidenceDetailView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct IncidenceDetailView: View {

    @Binding var incidence:   Incidence
    let adminId:              String
    let isResolving:          Bool
    let onResolve:            (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var resolution: String = ""
    @State private var showConfirm: Bool  = false
    
    // Configuración de validación
    private let charLimit = 150

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                   
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(Color("ColorPrimary"))
                        }

                        Text("Detalle de incidencia")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .padding(.leading, 8)

                        Spacer()
                    }
                    .padding(.bottom, 4)

                    // MARK: ID + Estado
                    HStack {
                        Text("#\(incidence.id.prefix(5).uppercased())")
                            .font(.title2.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        Spacer()
                        StatusBadge(
                            title:      incidence.status.displayName,
                            background: incidence.status == .open
                                ? Color("ColorSecondary").opacity(0.15)
                                : Color.green.opacity(0.15),
                            foreground: incidence.status == .open
                                ? Color("ColorSecondary")
                                : .green
                        )
                    }

                    // MARK: Info
                    infoCard {
                        infoRow(label: "Tipo",   value: incidence.type.displayName)
                        infoRow(label: "Canal",  value: incidence.channel.displayName)
                        infoRow(label: "Pedido", value: "#\(incidence.orderId.prefix(5).uppercased())")
                        infoRow(label: "Fecha",  value: incidence.formattedCreatedAt)
                    }

                    // MARK: Descripción
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        Text(incidence.description)
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.7))
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // MARK: Evidencia
                    if let evidenceURL = incidence.evidenceURL,
                       !evidenceURL.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Evidencia")
                                .font(.subheadline.bold())
                                .foregroundColor(Color("ColorPrimary"))
                            
                            AsyncImage(url: URL(string: evidenceURL)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                case .failure:
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                        .frame(height: 100)
                                default:
                                    ProgressView()
                                        .frame(height: 100)
                                }
                            }
                        }
                    }

                    // MARK: Resolución (si ya está resuelta)
                    if incidence.status == .resolved,
                       let resText = incidence.resolution {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Resolución")
                                .font(.subheadline.bold())
                                .foregroundColor(Color("ColorPrimary"))
                            Text(resText)
                                .font(.subheadline)
                                .foregroundColor(Color("ColorPrimary").opacity(0.7))
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // MARK: Formulario de resolución (si está abierta)
                    if incidence.status == .open {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Nota de resolución")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Color("ColorPrimary"))
                                Spacer()
                                // Contador de caracteres
                                Text("\(resolution.count)/\(charLimit)")
                                    .font(.caption2.monospacedDigit())
                                    .foregroundColor(resolution.count >= charLimit ? .red : .gray)
                            }

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $resolution)
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("ColorPrimary").opacity(0.15), lineWidth: 1)
                                    )
                                    // Filtro de Números y Límite de caracteres
                                    .onChange(of: resolution) { newValue in
                                
                                        let filtered = newValue.filter { !$0.isNumber }
                                        
                        
                                        if filtered.count > charLimit {
                                            resolution = String(filtered.prefix(charLimit))
                                        } else {
                                            resolution = filtered
                                        }
                                    }
                                
                                if resolution.isEmpty {
                                    Text("Describe cómo se resolvió (solo letras)...")
                                        .font(.subheadline)
                                        .foregroundColor(Color("ColorPrimary").opacity(0.3))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            }

                            Button {
                                hideKeyboard()
                                showConfirm = true
                            } label: {
                                if isResolving {
                                    ProgressView().tint(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                } else {
                                    Text("Marcar como resuelta")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(resolution.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : Color("ColorSecondary"))
                            )
                           
                            .disabled(isResolving || resolution.trimmingCharacters(in: .whitespaces).isEmpty)
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog(
            "¿Confirmar resolución?",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Resolver") {
                onResolve(resolution)
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se notificará al cliente sobre la resolución de esta incidencia.")
        }
    }

    // MARK: - Helpers

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.5))
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary"))
        }
    }
}

// Helper para cerrar el teclado
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
