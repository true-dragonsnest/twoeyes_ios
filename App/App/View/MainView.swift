//
//  MainView.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

class MainViewModel: ObservableObject {
    enum Tab: String {
        case explore
        case addNews
        case settings
    }
    @Published var tab: Tab = .explore
}

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        contentView
            .onAppear {
                Task {
                    try? await CameraService.shared.checkAccess()
                }
            }
    }
    
    var contentView: some View {
        tabView
    }
    
    var tabView: some View {
        TabView(selection: $viewModel.tab) {
            ExploreView()
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Explore")
                }
                .tag(MainViewModel.Tab.explore)
            
            AddNewsView()
                .tabItem {
                    Image(systemName: "plus.app.fill")
                }
                .tag(MainViewModel.Tab.addNews)

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(MainViewModel.Tab.settings)
        }
        .font(.headline)
    }
}
 
