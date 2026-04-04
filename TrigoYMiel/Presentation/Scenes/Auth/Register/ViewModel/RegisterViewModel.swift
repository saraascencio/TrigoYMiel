//
//  RegisterViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    
    // MARK: - Input
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var referralCode: String = ""
   
    // MARK: - State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
   
    // Validaciones de formato / reglas de negocio (tiempo real)
    @Published var nameError: String? = nil
    @Published var phoneError: String? = nil
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var confirmPasswordError: String? = nil
   
    // Errores de "campo obligatorio" (solo después de intentar registrarse)
    @Published var nameRequiredError: String? = nil
    @Published var phoneRequiredError: String? = nil
    @Published var emailRequiredError: String? = nil
    @Published var passwordRequiredError: String? = nil
    @Published var confirmPasswordRequiredError: String? = nil
   
    // MARK: - Dependencies
    private let registerUseCase: RegisterUseCase
    private let onRegisterSuccess: (User) -> Void
   
    init(
        registerUseCase: RegisterUseCase,
        onRegisterSuccess: @escaping (User) -> Void
    ) {
        self.registerUseCase = registerUseCase
        self.onRegisterSuccess = onRegisterSuccess
    }
    
    // Validaciones de formato (tiempo real)
    
    private func validateName() {
        if name.isEmpty {
            nameError = nil
            return
        }
        
        // Solo permite letras y espacios
        let allowedCharacters = CharacterSet.letters.union(CharacterSet.whitespaces)
        let nameSet = CharacterSet(charactersIn: name)
        
        if !allowedCharacters.isSuperset(of: nameSet) {
            nameError = "El nombre solo puede contener letras y espacios"
        } else if name.count < 2 {
            nameError = "El nombre debe tener al menos 2 caracteres"
        } else if name.count > 100 {
            nameError = "El nombre es demasiado largo"
        } else {
            nameError = nil
        }
    }
   
    private func validatePhone() {
        if phone.isEmpty {
            phoneError = nil
            return
        }
        
        let cleanPhone = phone.replacingOccurrences(of: "-", with: "")
        
        if cleanPhone.count != 8 {
            phoneError = "El teléfono debe tener 8 dígitos"
        } else {
            phoneError = nil
        }
    }
   
    private func validateEmail() {
        if email.isEmpty {
            emailError = nil
            return
        }
        
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        emailError = predicate.evaluate(with: email) ? nil : "Por favor ingresa un email válido"
    }
   
    private func validatePassword() {
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
   
    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = nil
            return
        }
        
        if confirmPassword != password {
            confirmPasswordError = "Las contraseñas no coinciden"
        } else {
            confirmPasswordError = nil
        }
    }
   
    // MARK: - Validación de campos requeridos (solo al hacer clic)
    private func validateRequiredFields() {
        nameRequiredError = name.isEmpty ? "El nombre es obligatorio" : nil
        phoneRequiredError = phone.isEmpty ? "El teléfono es obligatorio" : nil
        emailRequiredError = email.isEmpty ? "El email es obligatorio" : nil
        passwordRequiredError = password.isEmpty ? "La contraseña es obligatoria" : nil
        confirmPasswordRequiredError = confirmPassword.isEmpty ? "Debes confirmar la contraseña" : nil
    }
   
    private func hasAnyError() -> Bool {
        nameRequiredError != nil || phoneRequiredError != nil ||
        emailRequiredError != nil || passwordRequiredError != nil ||
        confirmPasswordRequiredError != nil ||
        nameError != nil || phoneError != nil ||
        emailError != nil || passwordError != nil || confirmPasswordError != nil
    }
   
    // MARK: - Actions
    func register() async {
        errorMessage = nil
        
        validateRequiredFields()
        validateName()
        validatePhone()
        validateEmail()
        validatePassword()
        validateConfirmPassword()
        
        // Sin mensaje general repetitivo
        if hasAnyError() {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await registerUseCase.execute(
                name: name,
                phone: phone,
                email: email,
                password: password,
                confirmPassword: confirmPassword,
                referralCode: referralCode.isEmpty ? nil : referralCode
            )
            onRegisterSuccess(user)
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
   
    // MARK: - Métodos llamados desde la vista al cambiar texto
    
    func nameDidChange() {
        // Filtrar: solo permite letras y espacios
        let filtered = name.filter { $0.isLetter || $0.isWhitespace }
        if filtered != name {
            name = filtered
        }
        
        validateName()
        clearError()
        if !name.isEmpty { nameRequiredError = nil }
    }
   
    func phoneDidChange() {
        // Formateo automático 1234-5678
        var clean = phone.replacingOccurrences(of: "-", with: "")
            .filter { $0.isNumber }
        
        if clean.count > 8 {
            clean = String(clean.prefix(8))
        }
        
        if clean.count > 4 {
            let first = String(clean.prefix(4))
            let second = String(clean.dropFirst(4))
            phone = "\(first)-\(second)"
        } else {
            phone = clean
        }
        
        validatePhone()
        clearError()
        if !phone.isEmpty { phoneRequiredError = nil }
    }
   
    func emailDidChange() {
        validateEmail()
        clearError()
        if !email.isEmpty { emailRequiredError = nil }
    }
   
    func passwordDidChange() {
        validatePassword()
        validateConfirmPassword()
        clearError()
        if !password.isEmpty { passwordRequiredError = nil }
    }
   
    func confirmPasswordDidChange() {
        validateConfirmPassword()
        clearError()
        if !confirmPassword.isEmpty { confirmPasswordRequiredError = nil }
    }
}
