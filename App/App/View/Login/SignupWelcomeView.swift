//
//  SignupWelcomeView.swift
//  Nest3
//
//  Created by Yongsik Kim on 2023/06/11.
//

import SwiftUI

private let T = #fileID

struct SignupWelcomeView: View {
    @EnvironmentObject var introViewModel: IntroViewModel

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            Text("SignupWelcomeView")
                .foregroundStyle(.label1)
                .font(.largeTitle)
            
            VStack {
                Spacer()
                
                Button(action: {
                    Task {
                        do {
                            try await introViewModel.checkAuth()
                        } catch {
                            ContentViewModel.shared.setError(error)
                        }
                    }
                }) {
                    Text("Next")
                        .foregroundStyle(.white)
                        .padding()
                        .background(.appPrimary)
                        .clipShape(.capsule)
                }
                .padding(.bottom)
            }
            
            // FIXME: request required access from users here!
        }
    }
}
