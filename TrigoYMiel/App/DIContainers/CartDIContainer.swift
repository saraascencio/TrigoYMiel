//
//  CartDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
// App/DIContainers/CartDIContainer.swift
// App/DIContainers/CartDIContainer.swift

/*import Foundation

final class CartDIContainer {
    
    // Repository (ya lo tienes implementado)
    private let cartRepository: CartRepository = CartRepositoryImpl()
    
    // MARK: - Use Cases
    
    func makeAddToCartUseCase() -> AddToCartUseCase {
        AddToCartUseCase(
            cartRepository: cartRepository,
            validateCartLimits: makeValidateCartLimitsUseCase()   // ← ahora sí se pasa
        )
    }
    
    func makeUpdateCartItemUseCase() -> UpdateCartItemUseCase {
        UpdateCartItemUseCase(
            cartRepository: cartRepository,
            validateCartLimits: makeValidateCartLimitsUseCase()
        )
    }
    
    func makeRemoveFromCartUseCase() -> RemoveFromCartUseCase {
        RemoveFromCartUseCase(cartRepository: cartRepository)
    }
    
    func makeValidateCartLimitsUseCase() -> ValidateCartLimitsUseCase {
        ValidateCartLimitsUseCase()   // ← no recibe parámetros en el init
    }
    
    func makeGetCartUseCase() -> GetCartUseCase {
        GetCartUseCase(cartRepository: cartRepository)
    }
    
    // MARK: - ViewModel (opcional por ahora)
    func makeCartViewModel() -> CartViewModel {
        CartViewModel(
            getCartUseCase: makeGetCartUseCase(),
            updateCartItemUseCase: makeUpdateCartItemUseCase(),
            removeFromCartUseCase: makeRemoveFromCartUseCase()
        )
    }
    func makeCartRepository() -> CartRepository {
        return cartRepository
    }
}*/
import Foundation

final class CartDIContainer {

    // 1. Necesitamos el repositorio de órdenes para las validaciones de límites
        // Podemos crear una instancia interna o recibirla en el init
        private lazy var orderRepository: OrderRepository = {
            OrderRepositoryImpl()
        }()

        private lazy var cartRepository: CartRepository = {
            CartRepositoryImpl() // Tu implementación actual
        }()

        // MARK: - Use Cases
        func makeCartRepository() -> CartRepository {
            return cartRepository
        }
    
        func makeAddToCartUseCase() -> AddToCartUseCase {
            AddToCartUseCase(
                cartRepository: cartRepository,
                orderRepository: orderRepository,                     // 2. CORRECCIÓN: Pasamos el repositorio al inicializar el UseCase
                validateCartLimits: ValidateCartLimitsUseCase(cartRepository: cartRepository, orderRepository: orderRepository)
            )
        }

        func makeUpdateCartItemUseCase() -> UpdateCartItemUseCase {
            UpdateCartItemUseCase(
                cartRepository: cartRepository,
                orderRepository: orderRepository,                     // 2. CORRECCIÓN: Pasamos el repositorio aquí también
                validateCartLimits: ValidateCartLimitsUseCase(cartRepository: cartRepository, orderRepository: orderRepository)
            )
        }
    func makeRemoveFromCartUseCase() -> RemoveFromCartUseCase {
        RemoveFromCartUseCase(cartRepository: cartRepository)
    }

    func makePlaceOrderUseCase() -> PlaceOrderUseCase {
        PlaceOrderUseCase(
            orderRepository: orderRepository,
            cartRepository:  cartRepository
        )
    }

    func makeCartViewModel(currentUser: User) -> CartViewModel {
        CartViewModel(
            currentUser:            currentUser,
            cartRepository:         cartRepository,
            addToCartUseCase:       makeAddToCartUseCase(),
            updateCartItemUseCase:  makeUpdateCartItemUseCase(),
            removeFromCartUseCase:  makeRemoveFromCartUseCase(),
            placeOrderUseCase:      makePlaceOrderUseCase()
        )
    }
}
