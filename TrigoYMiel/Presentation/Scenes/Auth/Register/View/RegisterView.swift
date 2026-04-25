//
//  RegisterView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel
    @EnvironmentObject private var router: AuthRouter
    @State private var showReferralInfo = false
    
    // Estados para mostrar/ocultar contraseñas
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("LogoTrigoYMiel")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 160)
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                
                VStack(spacing: 20) {
                    // Nombre
                    fieldWithError(
                        title: "Nombre",
                        text: $viewModel.name,
                        placeholder: "Ingrese su nombre",
                        error: viewModel.nameError ?? viewModel.nameRequiredError
                    )
                    .onChange(of: viewModel.name) { _ in viewModel.nameDidChange() }
                    
                    // Teléfono
                    fieldWithError(
                        title: "Teléfono",
                        text: $viewModel.phone,
                        placeholder: "1234-5678",
                        keyboard: .numberPad,
                        error: viewModel.phoneError ?? viewModel.phoneRequiredError
                    )
                    .onChange(of: viewModel.phone) { _ in viewModel.phoneDidChange() }
                    
                    // Email
                    fieldWithError(
                        title: "Email",
                        text: $viewModel.email,
                        placeholder: "Ingrese su email",
                        keyboard: .emailAddress,
                        autocapitalization: .never,
                        error: viewModel.emailError ?? viewModel.emailRequiredError
                    )
                    .onChange(of: viewModel.email) { _ in viewModel.emailDidChange() }
                    
              
                    passwordField(
                        title: "Contraseña",
                        text: $viewModel.password,
                        placeholder: "Ingrese su contraseña",
                        isVisible: $isPasswordVisible,
                        error: viewModel.passwordError ?? viewModel.passwordRequiredError
                    )
                    .onChange(of: viewModel.password) { _ in viewModel.passwordDidChange() }
                    
                
                    passwordField(
                        title: "Confirmar contraseña",
                        text: $viewModel.confirmPassword,
                        placeholder: "Confirme su contraseña",
                        isVisible: $isConfirmPasswordVisible,
                        error: viewModel.confirmPasswordError ?? viewModel.confirmPasswordRequiredError
                    )
                    .onChange(of: viewModel.confirmPassword) { _ in viewModel.confirmPasswordDidChange() }
                    
                    // Código de invitación (opcional)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text("Código de invitación (opcional)")
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundStyle(Color("ColorPrimary"))
                            Button { showReferralInfo.toggle() } label: {
                                Image(systemName: "questionmark.circle")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("ColorPrimary").opacity(0.6))
                            }
                        }
                        TextField("Ingrese el código de invitación", text: $viewModel.referralCode)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .foregroundStyle(Color("ColorText"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("ColorPrimary").opacity(0.20), lineWidth: 1)
                            )
                        
                        if showReferralInfo {
                            Text("Si alguien te invitó, ingresa su código para activar beneficios de mayoreo.")
                                .font(.caption)
                                .foregroundStyle(Color("ColorPrimary").opacity(0.75))
                                .padding(10)
                                .background(Color("ColorAccent").opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 28)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 12)
                }
                
                Button {
                    Task { await viewModel.register() }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Regístrate")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color("ColorSecondary")))
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .disabled(viewModel.isLoading)
                
                Button { router.goBack() } label: {
                    Text("¿Ya tiene cuenta? ")
                        .foregroundColor(Color("ColorPrimary")) +
                    Text("Inicia sesión")
                        .foregroundColor(Color("ColorPrimary"))
                        .bold()
                }
                .font(.subheadline)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color("ColorBackground").ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // Campo normal (Nombre, Teléfono, Email)
    private func fieldWithError(title: String,
                               text: Binding<String>,
                               placeholder: String,
                               keyboard: UIKeyboardType = .default,
                               autocapitalization: TextInputAutocapitalization = .sentences,
                               error: String?) -> some View {
        
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
                .foregroundStyle(Color("ColorPrimary"))
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 50)
                
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
                    .foregroundStyle(Color("ColorText"))
                    .padding(.horizontal, 14)
                    .frame(height: 50)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("ColorPrimary").opacity(0.20), lineWidth: 1)
            )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
    
  
    private func passwordField(title: String,
                              text: Binding<String>,
                              placeholder: String,
                              isVisible: Binding<Bool>,
                              error: String?) -> some View {
        
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
                .foregroundStyle(Color("ColorPrimary"))
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 50)
                
                HStack {
                    if isVisible.wrappedValue {
                        TextField(placeholder, text: text)
                            .foregroundStyle(Color("ColorText"))
                            .padding(.horizontal, 14)
                            .frame(height: 50)
                    } else {
                        SecureField(placeholder, text: text)
                            .foregroundStyle(Color("ColorText"))
                            .padding(.horizontal, 14)
                            .frame(height: 50)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isVisible.wrappedValue.toggle()
                        }
                    } label: {
                        Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                            .foregroundStyle(Color("ColorPrimary").opacity(0.7))
                            .padding(.trailing, 12)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("ColorPrimary").opacity(0.20), lineWidth: 1)
            )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}
