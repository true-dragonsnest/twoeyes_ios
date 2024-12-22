//
//  IntroView.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI

private let T = #fileID

struct IntroView: View {
    @EnvironmentObject var viewModel: IntroViewModel

    var body: some View {
        Group {
            if viewModel.authState == .signOut {
                LoginView()
                    .environmentObject(viewModel)
            } else if viewModel.authState == .needSignUp {
                SignupView()
                    .environmentObject(viewModel)
                    .environment(\.authState, viewModel.authState)
                    .transition(.move(edge: .trailing))
            } else if viewModel.authState == .signIn {
                Text("MAIN")
            } else {
                splashView
            }
        }
    }

    var splashView: some View {
        Color.yellow.ignoresSafeArea()
            .overlay {
                Text("SPLASH").font(.largeTitle).bold()
            }
    }
}
