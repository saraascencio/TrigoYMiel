//
//  UserRole.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

// MARK: - UserRole
// Determina qué TabView se muestra después del login.
// El AppCoordinator lee este valor y navega al flujo correcto.
//
//  .client → ClientTabCoordinator  (Catálogo, Pedidos, Historial, Mayoreo)
//  .admin  → AdminTabCoordinator   (Pedidos, Catálogo, Inventario, Reportes, Incidencias)

enum UserRole: String, Codable {
    case client = "cliente"
    case admin  = "admin"
}
