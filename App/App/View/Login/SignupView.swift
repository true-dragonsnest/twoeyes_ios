//
//  SignupView.swift
//  Nest3
//
//  Created by Yongsik Kim on 2023/06/11.
//

import SwiftUI

private let T = #fileID

struct SignupView: View {
    @Bindable var viewModel = SignupViewModel()

    @Environment(\.authState) var authState

    var body: some View {
        NavigationStack(path: $viewModel.navPath) {
            SignupHelloView(viewModel: viewModel)
                .navigationDestination(for: SignupViewModel.NavPath.self) { stage in
                    switch stage {
                    case .personalInfo:
                        SignupPersonalInfoView(viewModel: viewModel)
                    case .welcome:
                        SignupWelcomeView()
                    }
                }
        }
    }
}
