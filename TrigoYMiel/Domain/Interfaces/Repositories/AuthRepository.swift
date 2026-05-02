//
//  AuthRepository.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - AuthRepository
// Protocolo que define las operaciones de autenticación.
// Los UseCases de Auth dependen de este protocolo, NUNCA de AuthRepositoryImpl.
// La implementación concreta (AuthRepositoryImpl) vive en la capa Data
// y utiliza Firebase Auth + Firestore.
//
// ¿Por qué es un protocolo aquí?
// Permite hacer testing con MockAuthRepository sin tocar Firebase,
// y permite cambiar el proveedor de auth en el futuro sin modificar
// ningún UseCase ni ViewModel.

protocol AuthRepository {
    
    /// Autentica al usuario con email y contraseña.
    /// Devuelve el User completo cargado desde Firestore.
    /// Lanza: .invalidCredentials, .userNotFound, .networkUnavailable
    func login(email: String, password: String) async throws -> User
    
    /// Crea una nueva cuenta y el documento de usuario en Firestore.
    /// Si referralCode no es nil, lo valida y activa el mayoreo del invitador.
    /// Lanza: .emailAlreadyInUse, .weakPassword, .invalidReferralCode
    func register(name: String, phone: String, email: String, password: String, referralCode: String?) async throws -> User
    
    /// Cierra la sesión activa en Firebase Auth y limpia la sesión local de CoreData.
    func logout() async throws
    
    /// Devuelve el usuario actualmente autenticado, o nil si no hay sesión.
    func currentUser() async throws -> User?
    
    func updateLocalSession(_ user: User)
}
