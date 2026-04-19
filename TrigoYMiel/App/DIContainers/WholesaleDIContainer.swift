//
//  WholesaleDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation

final class WholesaleDIContainer {

    private let referralRepository: ReferralRepository = ReferralRepositoryImpl()

    func makeInviteFriendUseCase() -> InviteFriendUseCase {
        InviteFriendUseCase(referralRepository: referralRepository)
    }

    func makeWholesaleViewModel(currentUser: User) -> WholesaleViewModel {
        WholesaleViewModel(
            userId:              currentUser.id,
            userTier:            currentUser.tier,
            inviteFriendUseCase: makeInviteFriendUseCase()
        )
    }
}
