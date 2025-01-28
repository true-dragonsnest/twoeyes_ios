//
//  HomeViewModel.swift
//  App
//
//  Created by Yongsik Kim on 1/27/25.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var navPath = NavigationPath()
    
    init() {
    }
}

// MARK: - navigation
extension HomeViewModel {
    struct NavPath: Identifiable, Equatable, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        enum ViewType {
            case talk
        }
        
        let id = UUID()
        let viewType: ViewType
        
        init(viewType: ViewType) {
            self.viewType = viewType
        }
    }
    
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

