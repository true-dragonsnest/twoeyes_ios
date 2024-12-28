//
//  MyHomeViewModel.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

class MyHomeViewModel: ObservableObject {
    struct NavPath: Identifiable, Equatable, Hashable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        enum ViewType {
            case noteCapture
            case noteEdit(model: NoteModel)
            case study
            case test
        }
        
        let id = UUID()
        let viewType: ViewType
        
        init(viewType: ViewType) {
            self.viewType = viewType
        }
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
