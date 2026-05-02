//
//  ProfileView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 1/5/26.
//
import SwiftUI
import Combine

struct ProfileView: View {

    @StateObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // MARK: Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(Color("ColorPrimary"))
                        }
                        Text("Mi perfil")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // MARK: Avatar
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color("ColorAccent").opacity(0.3))
                                .frame(width: 90, height: 90)
                            Text(String(viewModel.name.prefix(1)).uppercased())
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(Color("ColorPrimary"))
                        }

                        Text(viewModel.name)
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        // Rol + Tier
                        HStack(spacing: 8) {
                            roleBadge
                            if let tier = viewModel.tierDisplayName {
                                tierBadge(tier)
                            }
                        }

                        Text("Miembro desde \(viewModel.formattedRegisteredAt)")
                            .font(.caption)
                            .foregroundColor(Color("ColorPrimary").opacity(0.45))
                    }
                    .padding(.bottom, 28)

                    // MARK: Campos
                    VStack(spacing: 16) {

                        if viewModel.isAdmin {
                            // Admin — solo lectura
                            readOnlyField(label: "Nombre",   value: viewModel.name)
                            readOnlyField(label: "Email",    value: viewModel.email)
                            readOnlyField(label: "Teléfono", value: viewModel.phone)

                            adminNoteCard

                        } else {
                            // Cliente — editable
                            // Nombre
                            editableField(
                                label: "Nombre",
                                placeholder: "Tu nombre completo",
                                text: $viewModel.name,
                                error: viewModel.nameError,
                                keyboard: .default
                            ) {
                                viewModel.name = viewModel.filterNameOnly(viewModel.name)
                                viewModel.validateName()
                            }

                            // Email (sin cambios)
                            editableField(
                                label: "Email",
                                placeholder: "tu@correo.com",
                                text: $viewModel.email,
                                error: viewModel.emailError,
                                keyboard: .emailAddress
                            ) {
                                viewModel.validateEmail()
                            }

                            // Teléfono - Mejorado
                            editableField(
                                label: "Teléfono",
                                placeholder: "1234-5678",
                                text: $viewModel.phone,
                                error: viewModel.phoneError,
                                keyboard: .phonePad
                            ) {
                                viewModel.phone = viewModel.filterPhoneOnly(viewModel.phone)
                                viewModel.validatePhone()
                            }
                            
                            // Botón guardar
                            Button {
                                Task { await viewModel.saveChanges() }
                            } label: {
                                Group {
                                    if viewModel.isSaving {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Guardar cambios")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.isSaveButtonDisabled ? Color.gray.opacity(0.6) : Color("ColorSecondary"))
                            )
                            .disabled(viewModel.isSaveButtonDisabled)
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task { @MainActor in
                viewModel.loadUserData()   // Necesitas agregar este método
            }
        }
        .alert("Perfil actualizado",
               isPresented: $viewModel.savedSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Tus datos han sido actualizados correctamente.")
        }
        .alert("Error",
               isPresented: Binding(
                   get: { viewModel.errorMessage != nil },
                   set: { if !$0 { viewModel.errorMessage = nil } }
               )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Rol badge

    private var roleBadge: some View {
        Text(viewModel.roleDisplayName)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color("ColorPrimary"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func tierBadge(_ name: String) -> some View {
        Text(name)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color("ColorSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Campo solo lectura

    private func readOnlyField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(Color("ColorPrimary").opacity(0.6))
            Text(value.isEmpty ? "—" : value)
                .font(.subheadline)
                .foregroundColor(Color("ColorPrimary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("ColorPrimary").opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("ColorPrimary").opacity(0.10), lineWidth: 1)
                )
        }
    }

    // MARK: - Campo editable

    private func editableField(
        label:       String,
        placeholder: String,
        text:        Binding<String>,
        error:       String?,
        keyboard:    UIKeyboardType,
        onChange:    @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(Color("ColorPrimary").opacity(0.6))

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
                .foregroundColor(Color("ColorPrimary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            error != nil
                            ? Color.red.opacity(0.6)
                            : Color("ColorPrimary").opacity(0.20),
                            lineWidth: 1
                        )
                )
                .onChange(of: text.wrappedValue) { _ in onChange() }

            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Nota admin

    private var adminNoteCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .foregroundColor(Color("ColorPrimary").opacity(0.5))
            Text("Los datos del administrador solo pueden modificarse desde el panel.")
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.55))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("ColorAccent").opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 4)
    }
}
