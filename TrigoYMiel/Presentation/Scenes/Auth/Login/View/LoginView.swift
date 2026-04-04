//
//  LoginView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject private var router: AuthRouter
    
    // Estado para mostrar/ocultar la contraseña
    @State private var isPasswordVisible: Bool = false
  
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
                    // Email Field
                    fieldWithError(
                        title: "Email",
                        text: $viewModel.email,
                        placeholder: "Ingrese su email",
                        keyboard: .emailAddress,
                        autocapitalization: .never,
                        error: viewModel.emailError ?? viewModel.emailRequiredError
                    )
                    .onChange(of: viewModel.email) { _ in
                        viewModel.emailDidChange()
                    }
                   
                    // Password Field
                    passwordField(
                        title: "Contraseña",
                        text: $viewModel.password,
                        placeholder: "Ingrese su contraseña",
                        isVisible: $isPasswordVisible,
                        error: viewModel.passwordError ?? viewModel.passwordRequiredError
                    )
                    .onChange(of: viewModel.password) { _ in
                        viewModel.passwordDidChange()
                    }
                }
                .padding(.horizontal, 28)
              
                // Error general
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 12)
                }
              
                // Botón
                Button {
                    Task { await viewModel.login() }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Iniciar sesión")
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
            }
            .padding(.horizontal, 28)
          
            Button {
                router.goToRegister()
            } label: {
                Text("¿Nuevo por aquí? ")
                    .foregroundColor(Color("ColorPrimary")) +
                Text("Regístrate")
                    .foregroundColor(Color("ColorPrimary"))
                    .bold()
            }
            .font(.subheadline)
            .padding(.top, 16)
          
            Spacer(minLength: 32)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color("ColorBackground").ignoresSafeArea())
        .navigationBarHidden(true)
    }
   
    // MARK: - Campo normal (Email)
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
   
    // MARK: - Campo de contraseña 
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
               
                HStack(spacing: 0) {
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
                            .padding(.trailing, 14)
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
