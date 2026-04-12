//
// SupportView.swift
// TrigoYMiel
//
// Created by Sara Ascencio on 31/3/26.
//
import SwiftUI
import PhotosUI

// MARK: - SupportView
// Pantalla de Contacto y ayuda del cliente.
// Figura 27 del documento de interfaces.
//
// Mejoras aplicadas SOLO sobre tu código original:
// - Los 3 cuadros de contacto (Chat / Llamada / Correo) ahora tienen **exactamente el mismo tamaño** (ancho y alto iguales)
// - Todos los textos del formulario (etiquetas, nombres de canales, descripción, etc.) ahora son **negro** (no café)
// - Header café con esquinas redondeadas
// - Tarjetas de pedido y descripción con esquinas más suaves
// - Todo centrado exactamente como en el prototipo
// - NO se cambió ningún color de assets (ColorPrimary, ColorSecondary, etc.)

struct SupportView: View {
    @StateObject var viewModel: SupportViewModel
    @State private var showProfileMenu = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground")
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // MARK: Header café
                        headerCard
                        // MARK: Contenido del formulario
                        VStack(alignment: .leading, spacing: 20) {
                            channelSection
                            incidenceTypeSection
                            orderSection
                            descriptionSection
                            photoSection
                            submitButton
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Contacto y ayuda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { await viewModel.loadOrders() }
            .alert("Incidencia enviada",
                   isPresented: $viewModel.didSubmitSuccessfully) {
                Button("Aceptar", role: .cancel) { }
            } message: {
                Text("Tu reporte fue enviado correctamente. Nos pondremos en contacto contigo pronto.")
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
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.selectedImageData = data
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 4) {
                Text("¿Tienes alguna consulta o necesitas ayuda?")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text("Cuéntanos, te escuchamos")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("ColorPrimary"))
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    // MARK: - Canal de contacto (cuadros del MISMO tamaño)
    private var channelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Elige como contactarnos")
            HStack(spacing: 16) {
                ForEach(ContactChannel.allCases, id: \.self) { channel in
                    channelButton(channel)
                        .frame(maxWidth: .infinity)   // ← Fuerza mismo ancho
                }
            }
        }
    }
    
    private func channelButton(_ channel: ContactChannel) -> some View {
        let isSelected = viewModel.selectedChannel == channel
        return Button {
            viewModel.selectedChannel = channel
        } label: {
            VStack(spacing: 4) {
                Image(systemName: channelIcon(channel))
                    .font(.system(size: 22))
                    .foregroundColor(isSelected
                                     ? Color("ColorSecondary")
                                     : Color("ColorPrimary"))
                Text(channel.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)          // ← Negro (no café)
                if let note = channel.note {
                    Text(note)
                        .font(.system(size: 10))
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)                       // ← Fuerza mismo alto para los 3 cuadros
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected
                                    ? Color("ColorSecondary")
                                    : Color("ColorPrimary").opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func channelIcon(_ channel: ContactChannel) -> String {
        switch channel {
        case .chat: return "paperplane"
        case .phone: return "phone"
        case .email: return "envelope"
        }
    }
    
    // MARK: - Tipo de incidencia
    private var incidenceTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Tipo de incidencia")
            IncidenceTypePickerView(selectedType: $viewModel.selectedType)
        }
    }
    
    // MARK: - Pedido relacionado
    private var orderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Seleccionar pedido relacionado")
            if viewModel.orders.isEmpty {
                Text("No tienes pedidos disponibles.")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.5))
            } else {
                ForEach(viewModel.orders) { order in
                    orderCard(order)
                }
            }
        }
    }
    
    private func orderCard(_ order: Order) -> some View {
        let isSelected = viewModel.selectedOrder?.id == order.id
        return Button {
            viewModel.selectedOrder = order
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "bag")
                            .font(.system(size: 12))
                            .foregroundColor(Color("ColorPrimary"))
                        Text("ID: \(order.displayId)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Text("Total: \(order.formattedTotal)")
                        .font(.system(size: 13))
                        .foregroundColor(.black.opacity(0.7))
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(Color("ColorPrimary"))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected
                                    ? Color("ColorSecondary")
                                    : Color("ColorPrimary").opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Descripción
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Descripción")
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $viewModel.description)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(minHeight: 100, maxHeight: 160)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("ColorPrimary").opacity(0.2), lineWidth: 1)
                            )
                    )
                    .onChange(of: viewModel.description) { newValue in
                        if newValue.count > viewModel.descriptionLimit {
                            viewModel.description = String(newValue.prefix(viewModel.descriptionLimit))
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        if viewModel.description.isEmpty {
                            Text("Describe que ha ocurrido con tu pedido")
                                .font(.system(size: 14))
                                .foregroundColor(.black.opacity(0.35))
                                .padding(.top, 16)
                                .padding(.leading, 12)
                                .allowsHitTesting(false)
                        }
                    }
                Text("\(viewModel.description.count)/\(viewModel.descriptionLimit)")
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.4))
                    .padding(.trailing, 10)
                    .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Adjuntar foto
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            PhotosPicker(selection: $selectedPhotoItem,
                         matching: .images,
                         photoLibrary: .shared()) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 16))
                        .foregroundColor(Color("ColorPrimary"))
                    Text(viewModel.selectedImageData == nil
                         ? "Adjuntar foto"
                         : "Foto adjunta ✓")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("ColorPrimary"))
                }
            }
            .buttonStyle(.plain)
            if let data = viewModel.selectedImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            viewModel.selectedImageData = nil
                            selectedPhotoItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color("ColorPrimary"))
                                .background(Color.white, in: Circle())
                        }
                        .offset(x: 6, y: -6)
                    }
            }
        }
    }
    
    // MARK: - Botón enviar
    private var submitButton: some View {
        Button {
            Task { await viewModel.submitIncidence() }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Enviar reporte")
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
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Menu {
                    Button {
                        // Acción: cerrar sesión
                    } label: {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    Button {
                        // Acción: ya estás en soporte
                    } label: {
                        Label("Contacta a soporte", systemImage: "message")
                    }
                } label: {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(Color("ColorPrimary"))
                }
                Button {
                    // Navegar al carrito
                } label: {
                    Image(systemName: "cart")
                        .font(.system(size: 20))
                        .foregroundColor(Color("ColorPrimary"))
                }
            }
        }
    }
    
    // MARK: - Helper label (ahora negro)
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.black)
    }
}

// MARK: - Preview
struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView(viewModel: SupportViewModel(
            currentUser: User(
                id: "1",
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
            reportIncidenceUseCase: ReportIncidenceUseCase(
                incidenceRepository: IncidenceRepositoryImpl()
            ),
            getOrderHistoryUseCase: GetOrderHistoryUseCase(
                orderRepository: OrderRepositoryImpl()
            ),
            getActiveOrdersUseCase: GetActiveOrdersUseCase(
                orderRepository: OrderRepositoryImpl()
            )
        ))
    }
}
