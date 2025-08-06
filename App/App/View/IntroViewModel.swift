//
//  IntroViewModel.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI
import Combine

private let T = #fileID

class IntroViewModel: ObservableObject {
    enum AuthState: Equatable {
        case unknown
        case signOut
        case needSignUp
        case signIn
    }
    
    @Published var authState: AuthState = .unknown
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init() {
        initialSetup()
    }
    
    private func initialSetup() {
        Task {
            do {
                "trying to setup Supabase backend...".ld(T)
                try await SupabaseService.setup(.init(projectUrl: AppEnvironment.Supabase.projectUrl, apiKey: AppEnvironment.Supabase.apiKey))
                await AssetRepository.shared.loadIntro()
                
                "trying to setup S3 backend...".ld(T)
                S3StorageService.setup(.init(accessKey: AppEnvironment.S3.accessKey, secretKey: AppEnvironment.S3.secretKey, endpoint: AppEnvironment.S3.endpoint))
                try? await S3StorageService.shared.setup()
                
                "trying to start to observe auth...".ld(T)
                await startObserveAuth()
            } catch {
                "failed to initial setup. cannot proceed : \(error)".lf(T)
            }
        }
    }
}

// MARK: - auth

extension IntroViewModel {
    private func startObserveAuth() async {
        await SupabaseService.shared.authStatePub
            .receive(on: RunLoop.main)
            .sink { [weak self] val in
                guard let self else { return }
                "auth state change : \(val)".ld(T)
                
                switch val {
                case .signIn(let user):
                    "sign in".ld(T)
                    Task {
                        await self.handleSingIn(user: user)
                    }
                case .signOut:
                    Task { @MainActor in
                        self.authState = .signOut
                    }
                }
            }
            .store(in: &subscriptions)

        await SupabaseService.shared.authTokenPub
            .sink { val in
                "auth token changed : \(o: val)".ld(T)
            }
            .store(in: &subscriptions)
    }

    fileprivate func handleSingIn(user: SupabaseService.AuthUser) async {
        do {
            "sign in as : \(user.id)".li(T)
            if try await LoginUserModel.shared.login(userId: user.id) == false {
                "Need sign up".li(T)
                await MainActor.run { self.authState = .needSignUp }
            } else {
                await MainActor.run { self.authState = .signIn }
                await afterSignInProcess()
            }
        } catch {
            try? await LoginUserModel.shared.logout()
        }
    }

    private func afterSignInProcess() async {
        let authToken = SupabaseService.shared.authToken
        if let token = authToken {
            await HttpApiService.shared.setCommomHeader(forKey: "Authorization", value: "Bearer \(token)")
            "Set user auth token for API requests".ld(T)
        } else {
            "No auth token available".le(T)
        }
    }
    
    func checkAuth() async throws {
        guard let user = SupabaseService.shared.authUser else {
            throw AppError.generalError("sign up ok but sign in failed. Bug?".lf(T))
        }
        await handleSingIn(user: user)
    }
}
