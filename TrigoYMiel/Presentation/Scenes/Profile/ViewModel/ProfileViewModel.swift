//
//  ProfileViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 1/5/26.
//
import Foundation
import Combine
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

        // Info solo lectura
        var role: UserRole = .client
        var tier: ClientTier?
        var isAdmin: Bool = false
        var registeredAt: Date = Date()

        private let authRepository: AuthRepository
        private var currentUserId: String = ""

        // MARK: - Init

        // Init con usuario (para cuando ya lo tienes fresco)
        convenience init(currentUser: User, authRepository: AuthRepository) {
            self.init(authRepository: authRepository)
            self.loadUserData(currentUser)
        }

        // Init recomendado (sin usuario → carga fresco)
        init(authRepository: AuthRepository) {
            self.authRepository = authRepository
        }

        // MARK: - Cargar datos frescos
        func loadUserData(_ user: User? = nil) {
            if let user = user {
                assignUser(user)
            } else {
                Task { await fetchLatestUser() }
            }
        }

        private func assignUser(_ user: User) {
            self.currentUserId = user.id
            self.name          = user.name
            self.email         = user.email
            self.phone         = user.phone
            self.role          = user.role
            self.tier          = user.role == .client ? user.tier : nil
            self.isAdmin       = user.role == .admin
            self.registeredAt  = user.registeredAt
        }

        private func fetchLatestUser() async {
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
        guard let current = try? getCurrentUser() else { return false }
        return name  != current.name  ||
               email != current.email ||
               phone != current.phone
    }

    // MARK: - Validaciones
    private func allValid() -> Bool {
        validateName()
        validateEmail()
        validatePhone()
        return nameError == nil && emailError == nil && phoneError == nil
    }

    // MARK: - Guardar cambios (solo clientes)
    func saveChanges() async {
        guard !isAdmin else { return }
        guard allValid() else { return }

        isSaving = true
        errorMessage = nil

        do {
            guard var user = try await authRepository.currentUser() else {
                throw AppError.userNotFound
            }

            // Actualizar datos
            user = User(
                id:              user.id,
                name:            name.trimmingCharacters(in: .whitespaces),
                phone:           phone.trimmingCharacters(in: .whitespaces),
                email:           email.trimmingCharacters(in: .whitespaces),
                role:            user.role,
                tier:            user.tier,
                isActive:        user.isActive,
                registeredAt:    user.registeredAt,
                fcmToken:        user.fcmToken,
                wholesaleActive: user.wholesaleActive
            )

           
            try await updateUserInFirestore(user)
            try? (authRepository as? AuthRepositoryImpl)?.updateLocalSession(user)

            savedSuccess = true

        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
    
    private func updateUserInFirestore(_ user: User) async throws {
        let data = UserMapper.toFirestore(user)
        let ref  = FirestoreClient.shared.usersCollection.document(user.id)
        try await ref.updateData(data)
    }

    private func getCurrentUser() throws -> User? {
        nil
    }

    // MARK: - Filtros de input
    func filterNameOnly(_ value: String) -> String {
            value.filter { $0.isLetter || $0.isWhitespace }
        }

        func filterPhoneOnly(_ value: String) -> String {
            let digitsOnly = value.filter { $0.isNumber }
            let limited = String(digitsOnly.prefix(8))
            
            // Formato automático: 1234-5678
            if limited.count >= 5 {
                let firstPart = limited.prefix(4)
                let secondPart = limited.suffix(from: limited.index(limited.startIndex, offsetBy: 4))
                return "\(firstPart)-\(secondPart)"
            }
            return limited
        }

        // MARK: - Validaciones mejoradas
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
            isSaving ||
            nameError != nil ||
            emailError != nil ||
            phoneError != nil ||
            name.trimmingCharacters(in: .whitespaces).isEmpty ||
            email.trimmingCharacters(in: .whitespaces).isEmpty ||
            phone.trimmingCharacters(in: .whitespaces).isEmpty
        }
    
}
