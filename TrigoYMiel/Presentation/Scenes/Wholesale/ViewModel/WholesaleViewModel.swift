//
//  WholesaleViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class WholesaleViewModel: ObservableObject {

    // MARK: - Estado de UI
    @Published var referralCode:    ReferralCode? = nil
    @Published var promotions:      [Promotion]   = []
    @Published var isLoading:       Bool          = false
    @Published var errorMessage:    String?       = nil
    @Published var showShareSheet:  Bool          = false

    // MARK: - Tier reactivo
    // Se actualiza en tiempo real desde Firestore cuando el invitado se registra
    @Published var currentTier: ClientTier

    let userId: String

    // MARK: - UseCases
    private let inviteFriendUseCase:     InviteFriendUseCase
    private let getPromotionsDataSource: PromotionFirestoreDataSource

    // MARK: - Listener Firestore
    private var userListener: ListenerRegistration? = nil

    // MARK: - Init
    init(
        userId:              String,
        userTier:            ClientTier,
        inviteFriendUseCase: InviteFriendUseCase
    ) {
        self.userId              = userId
        self.currentTier         = userTier
        self.inviteFriendUseCase = inviteFriendUseCase
        self.getPromotionsDataSource = PromotionFirestoreDataSource()

        startListeningToWholesaleStatus()
    }

    deinit {
        userListener?.remove()
    }

    // MARK: - Listener en tiempo real
    // Escucha el campo wholesaleActive del usuario en Firestore.
    // Cuando el invitado se registra con el código, ReferralRepositoryImpl
    // actualiza wholesaleActive = true en el documento del invitador.
    // Este listener lo detecta y actualiza la UI automáticamente.

    private func startListeningToWholesaleStatus() {
        let ref = FirestoreClient.shared.usersCollection.document(userId)

        userListener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let data = snapshot?.data() else { return }

            let isWholesale = data["wholesaleActive"] as? Bool ?? false
            let newTier: ClientTier = isWholesale ? .wholesale : .retail

            Task { @MainActor in
                if newTier != self.currentTier {
                    self.currentTier = newTier
                    if newTier == .wholesale {
                        await self.loadPromotions()
                    }
                }
            }
        }
    }

    // MARK: - Load según tier

    func onAppear() async {
        if currentTier == .wholesale {
            await loadPromotions()
        }
    }

    // MARK: - Wholesale: cargar promociones activas
    private func loadPromotions() async {
        isLoading = true
        do {
            let all = try await getPromotionsDataSource.getActivePromotions()
            
            // Filtramos las promociones
            promotions = all.filter { $0.wholesaleOnly && $0.isCurrentlyValid }
            
            // Publicamos la notificación para que otros componentes (como el Carrito)
            // se enteren de que las promociones están listas
            NotificationCenter.default.post(
                name: .wholesalePromotionsLoaded,
                object: promotions
            )
            
        } catch {
            errorMessage = "No se pudieron cargar las promociones."
        }
        isLoading = false
    }
    // MARK: - Retail: obtener código de referido para compartir

    func fetchReferralCode() async {
        isLoading    = true
        errorMessage = nil
        do {
            referralCode   = try await inviteFriendUseCase.execute(userId: userId)
            showShareSheet = true
        } catch let appError as AppError {
            errorMessage = appError.errorDescription
        } catch {
            errorMessage = "No se pudo obtener el código de invitación."
        }
        isLoading = false
    }
}
