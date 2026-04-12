//
//  WholesaleViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//

import Foundation
import Combine

// MARK: - WholesaleViewModel
// Maneja el estado de la sección Mayoreo.
// Tiene dos estados visuales según el tier del usuario:
//
//  .retail    → WholesaleLockedView  (invitar amigo para desbloquear)
//  .wholesale → WholesaleActiveView  (ver promociones disponibles)
//
// Usado por: WholesaleView

@MainActor
final class WholesaleViewModel: ObservableObject {

    // MARK: - Estado de UI
    @Published var referralCode: ReferralCode? = nil
    @Published var promotions: [Promotion] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showShareSheet: Bool = false

    // Tier actual del usuario — determina qué subvista mostrar
    let userTier: ClientTier
    let userId: String

    // MARK: - UseCases
    private let inviteFriendUseCase: InviteFriendUseCase
    private let getPromotionsDataSource: PromotionFirestoreDataSource

    // MARK: - Init
    init(
        userId: String,
        userTier: ClientTier,
        inviteFriendUseCase: InviteFriendUseCase
    ) {
        self.userId               = userId
        self.userTier             = userTier
        self.inviteFriendUseCase  = inviteFriendUseCase
        self.getPromotionsDataSource = PromotionFirestoreDataSource()
    }

    // MARK: - Load según tier

    func onAppear() async {
        if userTier == .wholesale {
            await loadPromotions()
        }
    }

    // MARK: - Wholesale: cargar promociones activas
    private func loadPromotions() async {
        isLoading = true
        do {
            let all = try await getPromotionsDataSource.getActivePromotions()
            // Mostrar solo las que son para mayoristas y están vigentes
            promotions = all.filter { $0.wholesaleOnly && $0.isCurrentlyValid }
        } catch {
            errorMessage = "No se pudieron cargar las promociones."
        }
        isLoading = false
    }

    // MARK: - Retail: obtener código de referido para compartir
    func fetchReferralCode() async {
        isLoading = true
        errorMessage = nil
        do {
            referralCode = try await inviteFriendUseCase.execute(userId: userId)
            showShareSheet = true
        } catch let appError as AppError {
            errorMessage = appError.errorDescription
        } catch {
            errorMessage = "No se pudo obtener el código de invitación."
        }
        isLoading = false
    }
}
