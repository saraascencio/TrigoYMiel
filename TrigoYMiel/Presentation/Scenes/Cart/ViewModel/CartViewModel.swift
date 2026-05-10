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
        let minDate = minPickupDate
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
        let now = Date()
        
 
        let candidates = promotions.filter { promo in

            guard promo.isActive,
                  promo.startDate <= now,
                  now <= promo.endDate else { return false }
            

            let canView = !promo.wholesaleOnly || isWholesaleCustomer
            guard canView else { return false }
            
   
            let productMatches = promo.applicableProductIds.contains { id in
                let idStr = "\(id)".trimmingCharacters(in: .whitespacesAndNewlines)
                return idStr.contains(product.id) || product.id.contains(idStr)
            }
            
            return productMatches
        }
        
        // Priorizamos: Mayorista → primero las wholesaleOnly
        if isWholesaleCustomer {
            if let wholesalePromo = candidates.first(where: { $0.wholesaleOnly }) {
                return wholesalePromo
            }
        }
        
        // Sino devolvemos la de mayor descuento
        return candidates.max(by: { $0.discountPercentage < $1.discountPercentage })
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
        cartItems.reduce(0.0) { acc, item in
            guard let promo = activePromotion(for: item.product) else {
                return acc
            }
            
            let shouldApply: Bool = {
                if promo.wholesaleOnly {
                    return isWholesaleCustomer && item.quantity >= 75
                } else {
                    return true
                }
            }()
            
            guard shouldApply else { return acc }
            
            let discountAmount = item.subtotal * Double(promo.discountPercentage) / 100.0
            return acc + discountAmount
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
       
            try await addToCartUseCase.execute(
                product: item.product,
                quantity: newQuantity,
                userId: currentUser.id,
                currentCart: self.cartItems.filter { $0.id != item.id },
                tier: currentUser.tier
            )
            
            
            var updatedItem = item
            updatedItem.quantity = newQuantity
            
            
            try await cartRepository.updateItem(updatedItem, userId: currentUser.id)
            
           
            await loadCart()
            
        } catch let error as AppError {
           
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
