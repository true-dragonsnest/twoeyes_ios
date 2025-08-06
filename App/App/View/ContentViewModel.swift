//
//  ContentViewModel.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI

private let T = #fileID

class ContentViewModel: ObservableObject {
    static let shared = ContentViewModel()
    
    @Published private(set) var error: Error?
    @Published private(set) var toastMessage: String = ""
    @Published var showToast = false
    
    func handlePushTokenChanged(_: Notification) {
        "PUSH TOKEN CHANGED".ld(T)
        // FIXME: code this
    }

    func handlePushNotification(_: Notification, _: Bool) {
        "PUSH NOTIFICATION RECEIVED".ld(T)
        // FIXME: code this
    }
    
    func setError(_ error: Error) {
        self.error = error
        self.toastMessage = "common.error".localized
        self.showToast = true
        nextToastMessage()
    }
    
    func setToastMessage(_ message: String) {
        self.toastMessage = message
        self.showToast = true
        nextToastMessage()
    }
    
    private func nextToastMessage() {
        // FIXME: toast queue?
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.toastMessage = ""
            self.showToast = false
        }
    }
}
