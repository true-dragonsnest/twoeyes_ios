//
//  MyHomeViewModel.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

@Observable
class MyHomeViewModel {
    enum NavPath {
        case addNote
        case study
        case test
    }
    var navPath = NavigationPath()
    
    @MainActor
    func navPush(_ path: NavPath) {
        withAnimation {
            navPath.append(path)
        }
    }
    
    @MainActor
    func navPop() {
        withAnimation {
            navPath.removeLast()
        }
    }
    
    @MainActor
    func navPopToRoot() {
        withAnimation {
            navPath = .init()
        }
    }
}
