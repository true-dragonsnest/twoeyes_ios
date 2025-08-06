//
//  SignupPersonalInfoView.swift
//  Nest3
//
//  Created by Yongsik Kim on 2023/06/11.
//

import SwiftUI

private let T = #fileID

struct SignupPersonalInfoView: View {
    let viewModel: SignupViewModel

    @State var input: String = ""
    @FocusState var focused: Bool
    
    @State var errorMsg: String = ""
    @State var ableToNext = false
    @State var inProgress = false

    var body: some View {
        content
            .toolbarRole(.editor)
    }
    
    var content: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack {
                Spacer()

                Text("Please enter your ID")
                    .foregroundStyle(.label1)
                    .font(.largeTitle)
                
                HStack(spacing: 0) {
                    Text("@ ")
                        .foregroundStyle(.label1)
                        .font(.headline)
                    
                    TextField("ID", text: $input)
                        .foregroundStyle(.label1)
                        .font(.headline)
                        .keyboardType(.asciiCapable)
                        .fixedSize()
                        .onSubmit {
                            "submit : \(input)".ld(T)
                            trySignup()
                        }
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .focused($focused)
                }

                Spacer()

                Text(errorMsg)
                    .foregroundStyle(.error)
                    .font(.footnote)
                    .padding(.bottom)
                    .opacity(errorMsg.isEmpty ? 0 : 1)
                
                Button(action: {
                    trySignup()
                }) {
                    Text("Next")
                        .foregroundStyle(.white)
                        .padding()
                        .opacity(inProgress ? 0 : 1)
                        .overlay {
                            if inProgress {
                                ProgressView()
                            }
                        }
                        .background(.appPrimary)
                        .clipShape(.capsule)
                }
                .opacity(ableToNext ? 1 : 0)
                .padding(.bottom)
            }
        }
        .onChange(of: input) { _, val in
            checkUserId(val)
        }
        .onAppear {
            focused = true
        }
    }
}

// MARK: - actions
extension SignupPersonalInfoView {
    func checkUserId(_ userId: String) {
        var allowedCharSet = CharacterSet.alphanumerics.union(.whitespaces)
        allowedCharSet.insert(charactersIn: "_.")
        let new = String(userId.prefix(AppConst.maxUserIdLength))
            .lowercased()
            .removeCharacters(from: allowedCharSet.inverted)
            .replacingOccurrences(of: " ", with: "_")
        
        input = new
        if new.isEmpty {
            errorMsg = ""
            ableToNext = false
            return
        }
        
        if new.count < AppConst.minUserIdLength {
            errorMsg = "ID Too short".localized
            ableToNext = false
        } else {
            errorMsg = ""
            ableToNext = true
        }
    }
    
    func trySignup() {
        guard let user = SupabaseService.shared.authUser else {
            errorMsg = "common.error".localized
            return
        }
        
        Task {
            inProgress = true
            do {
                try await UseCases.Signup.execute(id: user.id,
                                                  userId: input,
                                                  nickname: user.userMetadata["name"]?.stringValue,
                                                  profilePictureUrl: user.userMetadata["picture"]?.stringValue)
            } catch {
                await MainActor.run {
                    if case .alreadyExists(_) = AppError(error) {
                        errorMsg = "ID already taken, please try another one".localized
                    } else {
                        errorMsg = "common.error".localized
                    }
                }
            }
            inProgress = false
            if errorMsg.isEmpty {
                viewModel.navPush(.welcome)
            }
        }
    }
}
