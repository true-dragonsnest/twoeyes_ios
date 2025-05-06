//
//  ContentView.swift
//  App
//
//  Created by Yongsik Kim on 12/21/24.
//

import SwiftUI
import AlertToast

private let T = #fileID

// MARK: - view

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @StateObject var introViewModel = IntroViewModel()
    
    @State var size: CGSize = .init(width: 1, height: 1)

    var body: some View {
        VStack {
            IntroView()
                .environmentObject(introViewModel)
                .environmentObject(viewModel)
        }
        .onReceive(PushNotificationService.Event.deviceTokenChanged.publisher) { notification in
            viewModel.handlePushTokenChanged(notification)
        }
        .onReceive(PushNotificationService.Event.foregroundNotificationReceived.publisher) { notification in
            viewModel.handlePushNotification(notification, true)
        }
        .onReceive(PushNotificationService.Event.remoteNotificationClicked.publisher) { notification in
            viewModel.handlePushNotification(notification, false)
        }
        .environment(\.sceneSize, size)
        .readSize { self.size = $0 }
        .toast(isPresenting: $viewModel.showToast) {
            AlertToast(displayMode: .hud, type: .regular, title: viewModel.toastMessage)
        }
    }
}
