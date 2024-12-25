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
            Color.primaryContainer.ignoresSafeArea()

            VStack {
                Spacer()

                Text("SignupHelloView")
                    .foregroundStyle(.onPrimaryContainer)
                    .font(.largeTitle)

                Spacer()

                Button(action: {
                    viewModel.navPush(.personalInfo)
                }) {
                    Text("Next")
                        .foregroundStyle(.onPrimaryAccent)
                        .padding()
                        .background(.primaryAccent)
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
