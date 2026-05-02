//
//  ProfileDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 1/5/26.
//
final class ProfileDIContainer {

    private let authRepository: AuthRepository = AuthRepositoryImpl()

    func makeProfileViewModel(currentUser: User) -> ProfileViewModel {
        ProfileViewModel(
            currentUser: currentUser,
            authRepository: authRepository
        )
    }

    
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(authRepository: authRepository)
    }
}

