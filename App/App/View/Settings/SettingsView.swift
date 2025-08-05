//
//  SettingsView.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var introViewModel: IntroViewModel
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        Text("Logout")
            .onTapGesture {
                Task {
                    do {
                        try await LoginUserModel.shared.logout()
                    } catch {
                        "failed to sign out : \(error)".le()
                        ContentViewModel.shared.setError(error)
                    }
                }
            }
    }
}
