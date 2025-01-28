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
        case home
        case settings
    }
    @Published var tab: Tab = .home
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
            Text("Explore")
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Explore")
                }
                .tag(MainViewModel.Tab.explore)

            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(MainViewModel.Tab.home)

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
 
