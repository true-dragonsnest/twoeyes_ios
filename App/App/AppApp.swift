//
//  AppApp.swift
//  App
//
//  Created by Yongsik Kim on 12/21/24.
//

import SwiftUI

private let T = #fileID

@main
struct AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) var scenePhase

    init() {
        "APP INIT".ld(T)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ContentViewModel.shared)
                .onOpenURL { url in
                    handleOpenUrl(url)
                }
                .onAppear {
                    UIApplication.shared.addKeyboardDismissTapGesture()
                }
        }
        .onChange(of: scenePhase) { _, val in
            switch val {
            case .active:
                "ScenePhase ACTIVE".ld(T)
            case .background:
                "ScenePhase BACKGROUND".ld(T)
            case .inactive:
                "ScenePhase INACTIVE".ld(T)
            default:
                "ScenePhase UNKNOWN : \(val)".ld(T)
            }
        }
    }
}

// MARK: - open url
extension AppApp {
    func handleOpenUrl(_ url: URL) {
        "onOpenURL : \(url)".ld(T)
        if GoogleAuthService.shared.handleOpenUrl(url) {
            "handled by Google sign in".ld(T)
            return
        }
    }
}
