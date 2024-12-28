//
//  SignupViewModel.swift
//  Nest3
//
//  Created by Yongsik Kim on 2023/06/11.
//

import SwiftUI
import Combine

private let T = #fileID

@Observable
class SignupViewModel {
    var name: String?
    var id: String?
    var gender: EntityUser.Gender?
    var profilePic: UIImage?
    
    enum NavPath {
        case personalInfo
        case welcome
        // TODO: invite friend during sign up flow?
    }
    var navPath = NavigationPath()

    @MainActor
    func navPush(_ path: NavPath) {
        navPath.append(path)
    }
    
    @MainActor
    func navPop() {
        navPath.removeLast()
    }
}
