//
//  ThreadHomeViewModel.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI

@Observable
class ThreadHomeViewModel {
    enum NavPath: Hashable {
        case thread(_ entity: EntityThread)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .thread(let entity):
                hasher.combine("thread")
                hasher.combine(entity.id)
            }
        }
        
        static func == (lhs: NavPath, rhs: NavPath) -> Bool {
            switch (lhs, rhs) {
            case (.thread(let entity1), .thread(let entity2)):
                return entity1 == entity2
            default:
                return false
            }
        }
    }
    
    var navPath = NavigationPath()
    
    // MARK: - Navigation
    func navToThread(_ entity: EntityThread) {
        navPath.append(NavPath.thread(entity))
    }
    
    func popToRoot() {
        navPath.removeLast(navPath.count)
    }
    
    func popLast() {
        if !navPath.isEmpty {
            navPath.removeLast()
        }
    }
}
