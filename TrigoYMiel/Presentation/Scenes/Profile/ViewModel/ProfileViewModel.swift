//
//  ProfileViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 1/5/26.
//

import Foundation
import Combine
import FirebaseAuth
internal import FirebaseFirestoreInternal

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - State
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var isSaving = false
    @Published var errorMessage: String? = nil
    @Published var savedSuccess = false
    
    @Published var nameError: String? = nil
    @Published var emailError: String? = nil
    @Published var phoneError: String? = nil
    @Published var verificationEmailSent = false
    
    // Info solo lectura
    var role: UserRole = .client
    var tier: ClientTier?
    var isAdmin: Bool = false
    var registeredAt: Date = Date()
    
    private let authRepository: AuthRepository
    private var currentUserId: String = ""
    
    // Almacena el estado original para detectar cambios reales
    private var initialUser: User?
    
    // MARK: - Init
    @Published var isLoggedIn: Bool = false
    private var authListener: AuthStateDidChangeListenerHandle?
    
    convenience init(currentUser: User, authRepository: AuthRepository) {
        self.init(authRepository: authRepository)
        self.loadUserData(currentUser)
    }
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
        
            Task { @MainActor in
                self?.isLoggedIn = (user != nil)
            }
        }
    }
    
    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
    
    // MARK: - Cargar datos
    func loadUserData(_ user: User? = nil) {
        if let user = user {
            assignUser(user)
        } else {
            Task { await fetchLatestUser() }
        }
    }
    
    private func assignUser(_ user: User) {
        self.initialUser = user // <-- Guardamos la referencia original aquí
        self.currentUserId = user.id
        self.name          = user.name
        self.email         = user.email
        self.phone         = user.phone
        self.role          = user.role
        self.tier          = user.role == .client ? user.tier : nil
        self.isAdmin       = user.role == .admin
        self.registeredAt  = user.registeredAt
    }
    
  
    
    // MARK: - Computed
    var roleDisplayName: String {
        switch role {
        case .admin:  return "Administrador"
        case .client: return "Cliente"
        }
    }
    
    var tierDisplayName: String? {
        guard let tier = tier else { return nil }
        switch tier {
        case .retail:    return "Minorista"
        case .wholesale: return "Mayorista"
        }
    }
    
    var formattedRegisteredAt: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale    = Locale(identifier: "es_SV")
        return f.string(from: registeredAt)
    }
    
    var hasChanges: Bool {
        guard let current = initialUser else { return false }
        return name.trimmingCharacters(in: .whitespaces)  != current.name  ||
        email.trimmingCharacters(in: .whitespaces) != current.email ||
        phone.trimmingCharacters(in: .whitespaces) != current.phone
    }
    
    // MARK: - Validaciones
    private func allValid() -> Bool {
        validateName()
        validateEmail()
        validatePhone()
        return nameError == nil && emailError == nil && phoneError == nil
    }
    
    private func updateEmailInFirebaseAuth(_ newEmail: String) async throws {
        guard let firebaseUser = Auth.auth().currentUser else {
            throw AppError.userNotFound
        }
        try await firebaseUser.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
    
    // MARK: - Cargar datos modificado
        private func fetchLatestUser() async {

            guard !verificationEmailSent else { return }
            
            do {
                guard let user = try await authRepository.currentUser() else {
                    errorMessage = "Usuario no encontrado"
                    return
                }
                assignUser(user)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        // MARK: - Guardar Cambios Modificado
        func saveChanges() async {
            guard !isAdmin else { return }
            guard allValid() else { return }

            isSaving = true
            errorMessage = nil

            do {
                guard var user = try await authRepository.currentUser() else {
                    throw AppError.userNotFound
                }

                let newEmail     = email.trimmingCharacters(in: .whitespaces)
                let emailChanged = newEmail != Auth.auth().currentUser?.email

                if emailChanged {
                
                    if let authListener = self.authListener {
                        Auth.auth().removeStateDidChangeListener(authListener)
                        self.authListener = nil
                    }
                    
                  
                    try await updateEmailInFirebaseAuth(newEmail)
                    
                  
                    self.verificationEmailSent = true
                }

                user = User(
                    id:              user.id,
                    name:            name.trimmingCharacters(in: .whitespaces),
                    phone:           phone.trimmingCharacters(in: .whitespaces),
                    email:           user.email, // Mantiene el viejo en Firestore
                    role:            user.role,
                    tier:            user.tier,
                    isActive:        user.isActive,
                    registeredAt:    user.registeredAt,
                    fcmToken:        user.fcmToken,
                    wholesaleActive: user.wholesaleActive
                )
                
                try await updateUserInFirestore(user)
                (authRepository as? AuthRepositoryImpl)?.updateLocalSession(user)

                self.savedSuccess = true

            } catch let error as NSError {
                // Si el correo ya se envió o es un error de token por el cambio, lo tratamos como éxito
                let newEmail = email.trimmingCharacters(in: .whitespaces)
                let emailChanged = newEmail != Auth.auth().currentUser?.email
                
                if emailChanged && (error.code == AuthErrorCode.userNotFound.rawValue || error.localizedDescription.contains("token") || self.verificationEmailSent) {
                    self.verificationEmailSent = true
                    self.savedSuccess = true
                    self.isSaving = false
                    return
                }
                
                errorMessage = translateFirebaseError(error)
            }

            isSaving = false
        }

        // MARK: - Cierre de Sesión Forzado por Seguridad
        func forceSignOut() {
            
            if let authListener = self.authListener {
                Auth.auth().removeStateDidChangeListener(authListener)
                self.authListener = nil
            }
            
           
            try? Auth.auth().signOut()
            
           
            Task { @MainActor in
              
                try? await authRepository.logout()
                
               
                self.isLoggedIn = false
            }
        }
    
    // MARK: - Traducir errores de Firebase
    private func translateFirebaseError(_ error: NSError) -> String {
        let code = AuthErrorCode(rawValue: error.code)
        switch code {
        case .requiresRecentLogin:
            try? Auth.auth().signOut()
            return "Tu sesión ha expirado. Por seguridad, vuelve a iniciar sesión e intenta de nuevo."
        case .emailAlreadyInUse:
            return "Este correo ya está registrado en otra cuenta."
        case .invalidEmail:
            return "El correo ingresado no es válido."
        case .networkError:
            return "Sin conexión a internet. Verifica tu red e intenta de nuevo."
        case .userNotFound:
            return "No se encontró tu cuenta. Inicia sesión nuevamente."
        case .userTokenExpired:
            try? Auth.auth().signOut()
            return "Tu sesión ha expirado. Por favor inicia sesión de nuevo."
        default:
            if error.localizedDescription.contains("credentials") ||
                error.localizedDescription.contains("no longer valid") {
                try? Auth.auth().signOut()
                return "Tu sesión ya no es válida. Por favor inicia sesión de nuevo."
            }
            return "Ocurrió un error inesperado. Intenta de nuevo."
        }
    }
    
    private func updateUserInFirestore(_ user: User) async throws {
        let data = UserMapper.toFirestore(user)
        let ref  = FirestoreClient.shared.usersCollection.document(user.id)
        try await ref.updateData(data)
    }
    
    // MARK: - Filtros de input
    func filterNameOnly(_ value: String) -> String {
        value.filter { $0.isLetter || $0.isWhitespace }
    }
    
    func filterPhoneOnly(_ value: String) -> String {
        let digitsOnly = value.filter { $0.isNumber }
        let limited = String(digitsOnly.prefix(8))
        
        if limited.count >= 5 {
            let firstPart = limited.prefix(4)
            let secondPart = limited.suffix(from: limited.index(limited.startIndex, offsetBy: 4))
            return "\(firstPart)-\(secondPart)"
        }
        return limited
    }
    
    // MARK: - Validaciones
    func validateName() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        nameError = trimmed.isEmpty ? "El nombre es obligatorio." :
        trimmed.count < 3 ? "Mínimo 3 caracteres." : nil
    }
    
    func validateEmail() {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let isValid = NSPredicate(format: "SELF MATCHES[c] %@", regex).evaluate(with: trimmed)
        
        emailError = trimmed.isEmpty ? "El email es obligatorio." :
        !isValid ? "Ingresa un email válido." : nil
    }
    
    func validatePhone() {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = trimmed.filter { $0.isNumber }
        
        phoneError = trimmed.isEmpty ? "El teléfono es obligatorio." :
        digits.count != 8 ? "Debe tener exactamente 8 dígitos." : nil
    }
    
    // MARK: - Estado del botón Guardar
    var isSaveButtonDisabled: Bool {
        // Ahora sí responde correctamente si no hay cambios reales creados
        isSaving || !hasChanges ||
        nameError != nil || emailError != nil || phoneError != nil ||
        name.trimmingCharacters(in: .whitespaces).isEmpty ||
        email.trimmingCharacters(in: .whitespaces).isEmpty ||
        phone.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    
}
