//
//  MainView.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

class MainViewModel: ObservableObject {
    enum Tab: String {
        case feeds
        case threads
        case addNews
        case settings
    }
    @Published var tab: Tab = .feeds
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
            FeedsView()
                .tabItem {
                    Image(systemName: "newspaper.fill")
                    Text("Feeds")
                }
                .tag(MainViewModel.Tab.feeds)
            
            ThreadsView()
                .tabItem {
                    Image(systemName: "eyes.inverse")
                    Text("Two Eyes")
                }
                .tag(MainViewModel.Tab.threads)
            
            AddNewsView()
                .tabItem {
                    Image(systemName: "plus.app.fill")
                    Text("Post")
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
 
