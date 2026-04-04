//
//  AppDIContainer.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import Combine

final class AppDIContainer: ObservableObject {
    let authDIContainer = AuthDIContainer()
}
