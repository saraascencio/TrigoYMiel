//
//  AppError.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - AppError
// Todos los errores posibles de la aplicación centralizados en un solo lugar.
// Los UseCases lanzan AppError. Los ViewModels lo capturan y lo convierten
// en mensajes legibles para el usuario.

enum AppError: Error, LocalizedError {

    // MARK: Auth
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case sessionExpired
    case unauthorized

    // MARK: Cart
    case cartLimitExceeded(max: Int)
    case maxProductTypesReached(max: Int)
    case productNotAvailable
    case insufficientStock(available: Int)

    // MARK: Orders
    case orderNotFound
    case orderAlreadyDelivered
    case invalidPickupTime

    // MARK: Wholesale
    case invalidReferralCode
    case referralCodeAlreadyUsed
    case wholesaleAlreadyActive

    // MARK: Inventory
    case insufficientStockForExit(available: Int)

    // MARK: Network / Data
    case networkUnavailable
    case firestoreError(String)
    case coreDataError(String)
    case decodingError
    case unknown(String)

    // MARK: - Mensajes para el usuario
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Correo o contraseña incorrectos."
        case .emailAlreadyInUse:
            return "Ya existe una cuenta con este correo."
        case .weakPassword:
            return "La contraseña debe tener al menos 6 caracteres."
        case .userNotFound:
            return "No se encontró el usuario."
        case .sessionExpired:
            return "Tu sesión ha expirado. Inicia sesión nuevamente."
        case .unauthorized:
            return "No tienes permiso para realizar esta acción."
        case .cartLimitExceeded(let max):
            return "No puedes agregar más de \(max) unidades de este producto."
        case .maxProductTypesReached(let max):
            return "Tu pedido ya tiene el máximo de \(max) tipos de producto."
        case .productNotAvailable:
            return "Este producto no está disponible por el momento."
        case .insufficientStock(let available):
            return "Solo hay \(available) unidades disponibles."
        case .orderNotFound:
            return "No se encontró el pedido."
        case .orderAlreadyDelivered:
            return "Este pedido ya fue entregado."
        case .invalidPickupTime:
            return "La hora de retiro seleccionada no es válida."
        case .invalidReferralCode:
            return "El código de invitación no es válido."
        case .referralCodeAlreadyUsed:
            return "Este código de invitación ya fue utilizado."
        case .wholesaleAlreadyActive:
            return "El acceso a mayoreo ya está activo en tu cuenta."
        case .insufficientStockForExit(let available):
            return "No puedes registrar una salida mayor al stock actual (\(available) unidades)."
        case .networkUnavailable:
            return "Sin conexión a internet. Verifica tu red e intenta de nuevo."
        case .firestoreError(let msg):
            return "Error de base de datos: \(msg)"
        case .coreDataError(let msg):
            return "Error de almacenamiento local: \(msg)"
        case .decodingError:
            return "Error al procesar los datos recibidos."
        case .unknown(let msg):
            return "Error inesperado: \(msg)"
        }
    }
}
