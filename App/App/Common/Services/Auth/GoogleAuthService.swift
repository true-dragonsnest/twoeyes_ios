//
//  GoogleAuthService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 5/6/24.
//

import Foundation
import Combine
import GoogleSignIn
import FirebaseCore

private let T = #fileID

public class GoogleAuthService {
    public typealias Tokens = (idToken: String, accessToken: String)
    
    private var userInfo = AuthUserInfo()
    
    public static let shared = GoogleAuthService()
    private init() {
    }
    
    public func handleOpenUrl(_ url: URL) -> Bool {
        "open url: \(url)".ld(T)
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    @MainActor
    public func login(completion: @escaping (Result<Tokens, AppError>) -> Void) {
        guard let clientId = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AppError.notInited("Firebase not configured".lf(T))))
            return
        }
        guard let presentingVC = UIApplication.shared.keyWindow?.rootViewController else {
            completion(.failure(AppError.notInited("no key window found. Bug!".lf(T))))
            return
        }
        
        userInfo = AuthUserInfo()
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error {
                "google sign in failed : \(error)".le(T)
                completion(.failure(AppError(error)))
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(AppError.invalidResponse("invalid id token during google sign in".le(T))))
                return
            }
            if let profile = user.profile {
                self.userInfo.name = profile.name
                self.userInfo.email = profile.email
                self.userInfo.profilePictureUrl = profile.imageURL(withDimension: 512)?.absoluteString
            }
            
            "google sign in ok : \(idToken), \(user.accessToken.tokenString)".ld(T)
            completion(.success((idToken: idToken, accessToken: user.accessToken.tokenString)))
        }
    }
    
    @MainActor
    public func asyncLogin() async throws -> Tokens {
        return try await withCheckedThrowingContinuation { [weak self] (cont: CheckedContinuation<Tokens, Error>) in
            guard let self else {
                cont.resume(throwing: AppError.aborted())
                return
            }
            self.login { result in
                switch result {
                case let .failure(error): cont.resume(throwing: error)
                case let .success(tokens): cont.resume(returning: tokens)
                }
            }
        }
    }
}
