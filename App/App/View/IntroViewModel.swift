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
                try await SupabaseService.setup(.init(projectUrl: AppKey.supabaseProjectUrl, apiKey: AppKey.supabaseApiKey))
                await AssetRepository.shared.loadIntro()
                
                "trying to setup S3 backend...".ld(T)
                S3StorageService.setup(.init(accessKey: AppKey.s3AccessKey, secretKey: AppKey.s3SecretKey, endpoint: AppKey.s3Endpoint))
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
                afterSignInProcess()
            }
        } catch {
            try? await LoginUserModel.shared.logout()
        }
    }

    private func afterSignInProcess() {
    }
    
    func checkAuth() async throws {
        guard let user = SupabaseService.shared.authUser else {
            throw AppError.generalError("sign up ok but sign in failed. Bug?".lf(T))
        }
        await handleSingIn(user: user)
    }
}
