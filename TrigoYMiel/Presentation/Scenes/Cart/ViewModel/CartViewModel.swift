//
//  CartViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
// Presentation/Scenes/Cart/ViewModel/CartViewModel.swift
import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject {
    
    // MARK: - State
    @Published var cartItems: [CartItem] = []
    @Published var promotions: [Promotion] = []
    @Published var isLoading: Bool = false
    @Published var isPlacing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var orderPlaced: Bool = false
    
    // MARK: - Pickup (single source of truth)
    @Published var pickupDate: Date = Date()
    @Published var additionalNotes: String = ""
    
    // MARK: - User
    let currentUser: User
    
    // MARK: - Dependencies
    private let cartRepository: CartRepository
    private let addToCartUseCase: AddToCartUseCase
    private let updateCartItemUseCase: UpdateCartItemUseCase
    private let removeFromCartUseCase: RemoveFromCartUseCase
    private let placeOrderUseCase: PlaceOrderUseCase
    private let promotionDataSource: PromotionFirestoreDataSource
    
    // MARK: - Init
    init(
        currentUser: User,
        cartRepository: CartRepository,
        addToCartUseCase: AddToCartUseCase,
        updateCartItemUseCase: UpdateCartItemUseCase,
        removeFromCartUseCase: RemoveFromCartUseCase,
        placeOrderUseCase: PlaceOrderUseCase
    ) {
        self.currentUser = currentUser
        self.cartRepository = cartRepository
        self.addToCartUseCase = addToCartUseCase
        self.updateCartItemUseCase = updateCartItemUseCase
        self.removeFromCartUseCase = removeFromCartUseCase
        self.placeOrderUseCase = placeOrderUseCase
        self.promotionDataSource = PromotionFirestoreDataSource()
        loadPromotions()
    }
    
    // MARK: - Promotions
    private func loadPromotions() {
        Task {
            do {
                let all = try await promotionDataSource.getActivePromotions()
                promotions = all.filter { promo in
                    // Regla: Si es wholesaleOnly, el usuario DEBE ser mayorista.
                    // Si NO es wholesaleOnly, entra para todos.
                    let canView = !promo.wholesaleOnly || isWholesaleCustomer
                    return promo.isCurrentlyValid && canView
                }
            } catch {
                print("Error cargando promociones en carrito: \(error)")
            }
        }
    }
    
    // MARK: - Calendar helpers
    private static func elSalvadorCalendar() -> Calendar {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "America/El_Salvador") ?? .current
        return cal
    }
    
    private static func wholesaleDefaultDate() -> Date {
        let cal = elSalvadorCalendar()
        let now = Date()
        
        let minDate = cal.date(byAdding: .day, value: 3, to: now) ?? now
        
        var comps = cal.dateComponents([.year, .month, .day], from: minDate)
        comps.hour = 10
        comps.minute = 0
        
        return cal.date(from: comps) ?? now
    }
    
    // MARK: - State
    var isEmpty: Bool {
        cartItems.isEmpty
    }
    
    var totalUnits: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    

    var isWholesaleEligible: Bool {
        guard isWholesaleCustomer else { return false }
        
        let minDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        
        return pickupDate >= minDate && totalUnits >= 75
    }
    
    
    
    // MARK: - Pickup sync
    func syncPickupDate() {
        let minDate = minPickupDate // Usamos la regla dinámica
        if pickupDate < minDate {
            pickupDate = minDate
        }
    }
    
    // MARK: - Load cart
    func loadCart() async {
        isLoading = true
        do {
            cartItems = try await cartRepository.getCartItems(userId: currentUser.id)
            
            syncPickupDate()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Promotions per item
    func activePromotion(for product: Product) -> Promotion? {
        // 1. Buscamos en el array de promociones cargadas
        return promotions.first { promo in
            
            // 2. Verificamos si el ID del producto está incluido.
            // Usamos 'contains' de forma que funcione tanto con Strings como con Referencias mapeadas.
            let isIncluded = promo.applicableProductIds.map { "\($0)" }.contains { idString in
                // Esto limpia la ruta completa (si existe) y deja solo el ID final
                idString.contains(product.id)
            }
            
            // 3. Regla de visibilidad:
            // Si NO es exclusiva de mayorista, cualquier usuario la aplica.
            // Si SI es exclusiva, el usuario debe tener el tier .wholesale.
            let canApply = !promo.wholesaleOnly || isWholesaleCustomer
            
            // 4. Retornamos la promo si cumple fecha, inclusión y permiso
            return promo.isCurrentlyValid && isIncluded && canApply
        }
    }
    
    // MARK: - Base
    
    var isWholesaleCustomer: Bool {
        currentUser.tier == .wholesale
    }
    
    // MARK: - Totals
    var totalBeforeDiscount: Double {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }
    
    var totalDiscount: Double {
        // Quitamos el guard que bloqueaba todo si no eras mayorista con 75 unidades
        return cartItems.reduce(0) { acc, item in
            guard let promo = activePromotion(for: item.product) else { return acc }
            
            // Lógica de aplicación:
            // 1. Si es promo mayorista: requiere ser mayorista Y tener >= 75 unidades
            // 2. Si es promo abierta: aplica siempre
            let applies = !promo.wholesaleOnly || (isWholesaleCustomer && totalUnits >= 75)
            
            if applies {
                let discount = item.subtotal * (promo.discountPercentage / 100)
                return acc + discount
            }
            
            return acc
        }
    }
    var total: Double {
        totalBeforeDiscount - totalDiscount
    }
    
    var formattedTotal: String {
        String(format: "$%.2f", total)
    }
    
    // MARK: - Actions
    func updateQuantity(_ item: CartItem, newQuantity: Int) async {
        self.errorMessage = nil
        
        do {
            // 1. Validar con el UseCase
            // Filtramos el carrito actual para que el UseCase no sume la cantidad vieja con la nueva
            try await addToCartUseCase.execute(
                product: item.product,
                quantity: newQuantity,
                userId: currentUser.id,
                currentCart: self.cartItems.filter { $0.id != item.id },
                tier: currentUser.tier
            )
            
            // 2. Crear una copia del item con la nueva cantidad
            var updatedItem = item
            updatedItem.quantity = newQuantity
            
            // 3. Usar el método existente en tu Repositorio
            try await cartRepository.updateItem(updatedItem, userId: currentUser.id)
            
            // 4. Refrescar la lista
            await loadCart()
            
        } catch let error as AppError {
            // Limpieza de mensaje para evitar el "Error inesperado"
            let rawMessage = error.errorDescription ?? "Límite alcanzado"
            self.errorMessage = rawMessage
                .replacingOccurrences(of: "Unknown error: ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "unknown", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                
        } catch {
            self.errorMessage = "No se pudo actualizar la cantidad."
        }
    }
    
    func removeItem(_ item: CartItem) async {
        do {
            try await removeFromCartUseCase.execute(
                productId: item.product.id,
                userId: currentUser.id
            )
            
            await loadCart()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Place order
    func placeOrder() async {
        guard !isEmpty else { return }
        
        isPlacing = true
        if cartItems.isEmpty || cartItems.contains(where: { $0.quantity <= 0 }) {
                self.errorMessage = "El carrito contiene productos inválidos."
                return
        }
        
        do {
            
            _ = try await placeOrderUseCase.execute(
                userId: currentUser.id,
                cart: cartItems,
                pickupDate: pickupDate,
                additionalNotes: additionalNotes,
                tier: currentUser.tier,
                total: self.total,
                discount: self.totalDiscount
            )
            
            cartItems = []
            orderPlaced = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isPlacing = false
    }
    
    var minPickupDate: Date {
        let cal = Calendar.current
        let now = Date()
        
    
        if isWholesaleCustomer && totalUnits >= 75 {
            return cal.date(byAdding: .day, value: 3, to: now) ?? now
        }
        
     
        return now
    }
}
