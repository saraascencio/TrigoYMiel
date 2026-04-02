//
//  CarItem.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - CartItem
// Representa un artículo dentro del carrito activo del cliente.
// Se persiste localmente en CoreData (CDCartItem) para funcionar offline.
// Al confirmar el pedido, se convierte en OrderItem con sus _snap.
//
// NO se guarda en Firestore directamente.
// El carrito vive solo en CoreData hasta que el cliente confirma el pedido.

struct CartItem: Identifiable, Equatable {
    let id: String          // UUID local, generado al agregar al carrito
    let product: Product    // referencia completa al producto del Domain
    var quantity: Int       // cantidad seleccionada (validada por ValidateCartLimitsUseCase)

    // MARK: - Computed helpers

    /// Subtotal calculado en tiempo real
    var subtotal: Double {
        product.unitPrice * Double(quantity)
    }

    /// Subtotal formateado para mostrar en la UI: "$7.00"
    var formattedSubtotal: String {
        String(format: "$%.2f", subtotal)
    }
}
