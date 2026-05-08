//
//  MyIncidencesView.swift
//  TrigoYMiel
//
//  Created by Walter Gonzalez on 7/5/26.
//
//  Pantalla "Mis reportes" — historial de incidencias del cliente.
//
//  Acceso: botón "Ver mis reportes" dentro de SupportView (parte inferior,
//  antes del botón "Enviar reporte"), o NavigationLink desde el menú de perfil.
//
//  Estados de incidencia manejados:
//    .open     → badge naranja "Abierta"  (el admin aún no ha respondido)
//    .resolved → badge verde  "Resuelta"  (el admin dejó nota de resolución)
//
//  Pantalla "Mis reportes" — historial de incidencias del cliente.
//  Acceso: botón "Ver mis reportes anteriores" en SupportView.
//
//  Reutiliza los componentes existentes del proyecto:
//    - IncidenceCard(incidence:userName:onTap:)  → declarado en IncidencesView.swift
//    - StatusBadge(title:background:foreground:) → declarado en AdminOrdersView.swift
//  No se redeclaran aquí para evitar conflictos de compilación.

import SwiftUI

// MARK: - MyIncidencesView

struct MyIncidencesView: View {

    @StateObject var viewModel: MyIncidencesViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if viewModel.incidences.isEmpty {
                emptyView
            } else {
                incidenceList
            }
        }
        .navigationTitle("Mis reportes")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .task { await viewModel.loadIncidences() }
    }

    // MARK: - Lista

    private var incidenceList: some View {
        ScrollView {
            VStack(spacing: 0) {
                summaryBanner
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.incidences) { incidence in
                        ClientIncidenceCard(incidence: incidence)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Banner de resolución del admin

    private func resolutionBanner(_ resolution: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 13))
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text("Respuesta del equipo")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.green)
                Text(resolution)
                    .font(.system(size: 12))
                    .foregroundColor(Color("ColorPrimary").opacity(0.7))
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Resumen (chips abiertos / resueltos)

    private var summaryBanner: some View {
        HStack(spacing: 10) {
            // Reutiliza StatusBadge existente (AdminOrdersView.swift)
            StatusBadge(
                title:      "\(viewModel.openCount) abiertas",
                background: Color("ColorSecondary").opacity(0.15),
                foreground: Color("ColorSecondary")
            )
            StatusBadge(
                title:      "\(viewModel.resolvedCount) resueltas",
                background: Color.green.opacity(0.12),
                foreground: Color.green
            )
            Spacer()
        }
    }

    // MARK: - Estado vacío

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 52))
                .foregroundColor(Color("ColorPrimary").opacity(0.3))
            Text("Sin reportes aún")
                .font(.title3.bold())
                .foregroundColor(Color("ColorPrimary"))
            Text("Cuando envíes un reporte desde Contacto y ayuda, aparecerá aquí con su estado.")
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary").opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Cargando

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(Color("ColorSecondary"))
            Text("Cargando reportes…")
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary").opacity(0.6))
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundColor(Color("ColorSecondary"))
            Text(message)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary").opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                Task { await viewModel.loadIncidences() }
            } label: {
                Text("Reintentar")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color("ColorSecondary"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Mis reportes")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("ColorPrimary"))
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("ColorPrimary"))
            }
        }
    }
}

// MARK: - ClientIncidenceCard

private struct ClientIncidenceCard: View {

    let incidence: Incidence

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("#\(incidence.id.prefix(5).uppercased())")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
                Spacer()
                // Badge de estado
                StatusBadge(
                    title:      incidence.status.displayName,
                    background: incidence.status == .open
                        ? Color("ColorSecondary").opacity(0.15)
                        : Color.green.opacity(0.12),
                    foreground: incidence.status == .open
                        ? Color("ColorSecondary")
                        : Color.green
                )
            }

            Text("Solución mediante: \(incidence.channel.displayName)")
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.6))

            Text(incidence.type.displayName)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary"))

            Text(incidence.formattedCreatedAt)
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.5))

            // Resolución del admin (solo si resuelta)
            if incidence.status == .resolved,
               let resolution = incidence.resolution,
               !resolution.isEmpty {
                Divider()
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Respuesta del equipo")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                        Text(resolution)
                            .font(.system(size: 12))
                            .foregroundColor(Color("ColorPrimary").opacity(0.7))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
    }
}


// MARK: - Preview

struct MyIncidencesView_Previews: PreviewProvider {
    static var previews: some View {
        MyIncidencesView(
            viewModel: MyIncidencesViewModel(
                currentUser: User(
                    id: "u1",
                    name: "Sara Ascencio",
                    phone: "7777-8888",
                    email: "sara@example.com",
                    role: .client,
                    tier: .retail,
                    isActive: true,
                    registeredAt: Date(),
                    fcmToken: nil,
                    wholesaleActive: false
                ),
                getMyIncidencesUseCase: GetMyIncidencesUseCase(
                    incidenceRepository: IncidenceRepositoryImpl()
                )
            )
        )
    }
}
