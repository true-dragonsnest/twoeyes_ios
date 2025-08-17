//
//  ThreadHomeViewModel.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI

@Observable
class ThreadHomeViewModel {
    // MARK: - Navigation
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
    
    // MARK: - init
    init() {
        Task {
            await fetchCategories()
        }
    }

    // MARK: - Categories
    static let allCategory: EntityCategory = .init(original: "All", translated: "All".localized)
    var categories: [EntityCategory] = [allCategory]
    var selectedCategory: EntityCategory = allCategory
    
    func fetchCategories() async {
        do {
            let fetchedCategories = try await UseCases.Categories.getCategories()
            await MainActor.run {
                self.categories = [Self.allCategory] + fetchedCategories
            }
        } catch {
            "Failed to fetch categories: \(error)".le()
        }
    }
    
    func selectCategory(_ category: EntityCategory) {
        selectedCategory = category
    }
}
