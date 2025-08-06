//
//  LoginView.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI

private let T = #fileID

struct LoginView: View {
    @EnvironmentObject var introViewModel: IntroViewModel

    var body: some View {
        GeometryReader { g in
            VStack {
                bannerArea
                    .frame(width: g.size.width)
                    .frame(height: g.size.height * 2 / 3)
                    .edgesIgnoringSafeArea(.top)

                buttonsArea
            }
        }
    }

    var bannerArea: some View {
        ZStack {
            Color.secondaryFill
            Text("banner area")
                .foregroundStyle(.label1)
        }
    }

    var buttonsArea: some View {
        ZStack {
            Color.background

            VStack {
                Spacer()

                Text("Continue with")
                    .foregroundStyle(.label1)
                    .font(.headline)
                    .bold()

                Spacer()

                HStack {
                    appleLoginButton

//                    Text("app.common.or")
//                        .font(.callout)
//                        .foregroundColor(.secondary)
//
//                    googleLoginButton
                }

                Spacer()
            }
        }
    }
    
    var appleLoginButton: some View {
        Button(action: {
            Task {
                do {
                    try await SupabaseService.shared.signInApple()
                } catch {
                    "apple login failed : \(error)".le(T)
                    ContentViewModel.shared.setError(error)
                }
            }
        }) {
            Image(systemName: "apple.logo")
                .font(.title)
                .foregroundColor(.label1)
                .padding()
                .background(.primaryFill)
                .clipShape(Circle())
        }
    }
    
    var googleLoginButton: some View {
        Button(action: {
            Task {
                do {
                    try await SupabaseService.shared.signInGoogle()
                } catch {
                    "google login failed : \(error)".le(T)
                    ContentViewModel.shared.setError(error)
                }
            }
        }) {
            Image(systemName: "apple.logo")
                .font(.title)
                .foregroundColor(.primary)
                .opacity(0)
                .overlay {
                    Image("google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
}

