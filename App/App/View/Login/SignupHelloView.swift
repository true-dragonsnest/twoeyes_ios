//
//  SignupHelloView.swift
//  Nest3
//
//  Created by Yongsik Kim on 2023/06/11.
//

import SwiftUI

private let T = #fileID

struct SignupHelloView: View {
    let viewModel: SignupViewModel

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack {
                Spacer()

                Text("SignupHelloView")
                    .foregroundStyle(.label1)
                    .font(.largeTitle)

                Spacer()

                Button(action: {
                    viewModel.navPush(.personalInfo)
                }) {
                    Text("Next")
                        .foregroundStyle(.white)
                        .padding()
                        .background(.appPrimary)
                        .clipShape(.capsule)
                }
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    SignupHelloView(viewModel: .init())
}
