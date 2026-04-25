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
        
        if currentUser.tier == .wholesale {
            loadPromotions()
        }
    }
    
    // MARK: - Promotions
    private func loadPromotions() {
        Task {
            do {
                let all = try await promotionDataSource.getActivePromotions()
                promotions = all.filter {
                    $0.wholesaleOnly && $0.isCurrentlyValid
                }
            } catch {
              
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
       
        guard isWholesaleCustomer else { return nil }
        
      
        return promotions.first {
            $0.isCurrentlyValid &&
            $0.wholesaleOnly &&
            $0.applicableProductIds.contains(product.id)
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
        
        guard isWholesaleCustomer && totalUnits >= 75 else { return 0 }
        
       
        return cartItems.reduce(0) { acc, item in
            let promo = activePromotion(for: item.product)
            let discount = promo.map {
                item.subtotal * ($0.discountPercentage / 100)
            } ?? 0
            return acc + discount
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
        if newQuantity <= 0 {
            await removeItem(item)
            return
        }
        
        do {
            try await updateCartItemUseCase.execute(
                item: item,
                newQuantity: newQuantity,
                userId: currentUser.id,
                currentCart: cartItems,
                tier: currentUser.tier
            )
            
            await loadCart()
            
        } catch {
            errorMessage = error.localizedDescription
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
