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
            Color.green.ignoresSafeArea()

            VStack {
                Spacer()

                Text("SignupHelloView")
                    .font(.largeTitle)

                Spacer()

                Button(action: {
                    viewModel.navPush(.personalInfo)
                }) {
                    Text("Next")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.capsule)
                }
                .padding(.bottom)
            }
        }
    }
}
