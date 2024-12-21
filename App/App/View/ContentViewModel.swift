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
    
    @Published var error: Error?
    
    func handlePushTokenChanged(_: Notification) {
        "PUSH TOKEN CHANGED".ld(T)
        // FIXME: code this
    }

    func handlePushNotification(_: Notification, _: Bool) {
        "PUSH NOTIFICATION RECEIVED".ld(T)
        // FIXME: code this
    }
}
