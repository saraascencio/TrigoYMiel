//
//  PlaceOrderUseCase.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation

// MARK: - PlaceOrderUseCase
// Confirma el pedido: lo crea en Firestore y vacía el carrito en CoreData.
// Construye los OrderItem con sus _snap a partir del carrito actual.
// Si el total de unidades supera 75, activa requiere_anticipacion = true.
//
// Secuencia:
//  1. Valida que el carrito no esté vacío.
//  2. Construye los OrderItem con _snap de precio, nombre e imagen.
//  3. Crea el Order en Firestore (orderRepository.placeOrder).
//  4. Vacía el carrito en CoreData SOLO si Firestore confirmó sin error.
//
// Usado por: CartViewModel (botón "Confirmar pedido")
final class PlaceOrderUseCase {

    private let orderRepository: OrderRepository
    private let cartRepository: CartRepository

    // Umbral de unidades que activa el aviso de anticipación
    private let advanceNoticeThreshold = 75

    init(
        orderRepository: OrderRepository,
        cartRepository: CartRepository
    ) {
        self.orderRepository = orderRepository
        self.cartRepository  = cartRepository
    }

    func execute(
        userId: String,
        cart: [CartItem],
        pickupDate: Date,
        additionalNotes: String,
        tier: ClientTier,
        total: Double,
        discount: Double     
    ) async throws -> Order {

        guard !cart.isEmpty else {
            throw AppError.unknown("El carrito está vacío.")
        }

        // Construir OrderItems con los datos (snap)
        let orderItems: [OrderItem] = cart.map { cartItem in
            OrderItem(
                productId: cartItem.product.id,
                nameSnap: cartItem.product.name,
                unitPriceSnap: cartItem.product.unitPrice,
                imageURLSnap: cartItem.product.imageURL,
                quantity: cartItem.quantity,
                subtotal: cartItem.subtotal
            )
        }

        let totalUnits      = orderItems.reduce(0) { $0 + $1.quantity }
        let requiresNotice  = totalUnits > advanceNoticeThreshold

        // Creamos la orden usando los valores calculados que vienen del ViewModel
        let order = Order(
            id: UUID().uuidString,
            userId: userId,
            createdAt: Date(),
            pickupDate: pickupDate,
            status: .pending,
            orderType: tier == .wholesale ? .wholesale : .retail,
            total: total,
            discountAmount: discount,
            additionalNotes: additionalNotes,
            items: orderItems,
            requiresAdvanceNotice: requiresNotice
        )


        let createdOrder = try await orderRepository.placeOrder(order)
        try await cartRepository.clearCart(userId: userId)

        return createdOrder
    }
}
