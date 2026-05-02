//
//  IncidencesView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct IncidencesView: View {

    @StateObject var viewModel: IncidencesViewModel
    let adminId:   String
    let onLogout:  () -> Void
    let onSupport: () -> Void
    let onProfile: () -> Void
    
    @State private var isShowingDetail    = false
    @State private var selectedIncidence: Incidence? = nil

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Button {
                        onSupport()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                    }

                    Text("Incidencias")
                        .font(.title.bold())
                        .foregroundColor(Color("ColorPrimary"))
                        .padding(.leading, 8)

                    Spacer()

                    ProfileMenuButton(
                        onLogout:     { onLogout() },
                        onSupport:    { onSupport() },
                        onProfile:    { onProfile() },
                        supportLabel: "Volver a inicio"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("ColorPrimary").opacity(0.6))
                    TextField("Busca por nombre del cliente", text: $viewModel.searchText)
                        .foregroundColor(Color("ColorPrimary"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color("ColorPrimary").opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(IncidenceTypeFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                title:      filter.rawValue,
                                isSelected: viewModel.selectedFilter == filter
                            ) {
                                viewModel.selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)

                // MARK: List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(Color("ColorSecondary"))
                    Spacer()
                } else if viewModel.filteredIncidences.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(Color("ColorPrimary").opacity(0.3))
                        Text("No hay incidencias")
                            .foregroundColor(Color("ColorPrimary").opacity(0.5))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredIncidences) { incidence in
                                IncidenceCard(
                                    incidence: incidence,
                                    userName:  viewModel.userNamesMap[incidence.userId] ?? "Cliente"
                                ) {
                                    selectedIncidence = incidence
                                    isShowingDetail   = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingDetail) {
                if let incidence = selectedIncidence {
                    IncidenceDetailView(
                        incidence: Binding(
                            get: {
                                viewModel.incidences.first(where: { $0.id == incidence.id }) ?? incidence
                            },
                            set: { _ in }
                        ),
                        adminId:     adminId,
                        isResolving: viewModel.isResolving
                    ) { resolution in
                        Task {
                            await viewModel.resolveIncidence(
                                incidenceId: incidence.id,
                                resolution:  resolution,
                                adminId:     adminId
                            )
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task { await viewModel.loadIncidences() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - IncidenceCard

struct IncidenceCard: View {

    let incidence: Incidence
    let userName:  String
    let onTap:     () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("#\(incidence.id.prefix(5).uppercased())")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))

                if incidence.status == .open {
                    StatusBadge(
                        title:      incidence.type.displayName,
                        background: Color("ColorSecondary").opacity(0.15),
                        foreground: Color("ColorSecondary")
                    )
                }

                Spacer()

                if incidence.status == .open {
                    Button(action: onTap) {
                        Text("Ver detalle")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("ColorSecondary"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }

            Text("Solución mediante: \(incidence.channel.displayName)")
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.6))

            Text(userName)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary"))

            Text(incidence.formattedCreatedAt)
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.5))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
