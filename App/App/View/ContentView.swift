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

    // subview view models
    @StateObject var introViewModel = IntroViewModel()
    
    @State var showErrorToast = false

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
        .onReceive(viewModel.error.publisher) { error in
            showErrorToast = true
        }
        .toast(isPresenting: $showErrorToast) {
            AlertToast(displayMode: .hud, type: .regular, title: "app.common.error".localized)
        }
    }
}
