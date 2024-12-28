//
//  MainView.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

struct MainView: View {
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
        TabView {
            Text("Explore")
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Explore")
                }
            MyHomeView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("My Notes")
                }
            Text("Study History")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("History")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .font(.headline)
    }
}
 
