//
//  LoginViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - Input
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Validaciones
    @Published var emailError: String? = nil          // formato
    @Published var passwordError: String? = nil       // formato
    @Published var emailRequiredError: String? = nil  // campo vacío
    @Published var passwordRequiredError: String? = nil
    
    // MARK: - Dependencies
    private let loginUseCase: LoginUseCase
    private let onLoginSuccess: (User) -> Void
    
    // MARK: - Init
    init(
        loginUseCase: LoginUseCase,
        onLoginSuccess: @escaping (User) -> Void   
    ) {
        self.loginUseCase = loginUseCase
        self.onLoginSuccess = onLoginSuccess
    }
    
    // MARK: - Validaciones de formato (tiempo real)
    private func validateEmailFormat() {
        if email.isEmpty {
            emailError = nil
            return
        }
        
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        
        emailError = predicate.evaluate(with: email) ? nil : "Por favor ingresa un email válido"
    }
    
    private func validatePasswordFormat() {
        if password.isEmpty {
            passwordError = nil
            return
        }
        
        if password.count < 6 {
            passwordError = "La contraseña debe tener al menos 6 caracteres"
        } else if password.count > 50 {
            passwordError = "La contraseña es demasiado larga"
        } else {
            passwordError = nil
        }
    }
    
    // Validación de campos requeridos (solo al hacer login)
    private func validateRequiredFields() {
        emailRequiredError = email.isEmpty ? "El email es obligatorio" : nil
        passwordRequiredError = password.isEmpty ? "La contraseña es obligatoria" : nil
    }
    
    // MARK: - Actions
    func login() async {
        errorMessage = nil
        
        validateRequiredFields()
        validateEmailFormat()
        validatePasswordFormat()
        
       
        if emailRequiredError != nil || passwordRequiredError != nil ||
           emailError != nil || passwordError != nil {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await loginUseCase.execute(email: email, password: password)
            onLoginSuccess(user)
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AppError.unknown(error.localizedDescription).errorDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // Llamados desde la vista al cambiar texto
    func emailDidChange() {
        validateEmailFormat()
        clearError()
        if !email.isEmpty {
            emailRequiredError = nil
        }
    }
    
    func passwordDidChange() {
        validatePasswordFormat()
        clearError()
        if !password.isEmpty {
            passwordRequiredError = nil
        }
    }
}
