//
//  AppleAuthService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/06/04.
//

import AuthenticationServices
import Foundation

private let T = #fileID

public extension ASAuthorizationAppleIDProvider.CredentialState {
    var desctiption: String {
        switch self {
        case .authorized: return "authorized"
        case .revoked: return "revoked"
        case .notFound: return "notFound"
        case .transferred: return "transferred"
        default:
            "UNKNOWN crendentialState = \(self)".le(T)
            return "UNKNOWN"
        }
    }
}

public class AppleAuthService: NSObject {
    public struct AuthContext {
        public let userIdentifier: String
        public let idToken: String
        public let nonce: String
    }

    private var inited = false
    private var appBundleId: String?

    public static let shared = AppleAuthService()
    override private init() {
        appBundleId = Bundle.main.bundleIdentifier
    }

    public func asyncLogin() async throws -> AuthContext {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthContext, Error>) in
            self.login { (result: Result<AuthContext, AppError>) in
                switch result {
                case let .failure(error): continuation.resume(throwing: error)
                case let .success(context): continuation.resume(returning: context)
                }
            }
        }
    }

    private var completionHandler: ((Result<AuthContext, AppError>) -> Void)?
    private var currentNonce: String?
    private(set) var userInfo = AuthUserInfo()

    public func login(completion: @escaping (Result<AuthContext, AppError>) -> Void) {
        completionHandler = completion
        userInfo = AuthUserInfo()

        let nonce = Self.randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
}

// MARK: - apple sign in delegates
extension AppleAuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.keyWindow!
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let nonce = currentNonce else {
                completionHandler?(.failure(.generalError("invalid nonce during apple sign in")))
                return
            }
            guard let idToken = appleIDCredential.identityToken, let idTokenStr = String(data: idToken, encoding: .utf8) else {
                completionHandler?(.failure(.generalError("invalid id token during apple sign in")))
                return
            }

            let userId = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            "appleIDCredential = \(idTokenStr), \(userId), \(o: email), \(o: fullName)".ld(T)

            userInfo.name = fullName?.formatted()
            userInfo.email = email
            "userInfo : \(o: userInfo.name), \(o: userInfo.email)".ld(T)

            completionHandler?(.success(AuthContext(userIdentifier: userId, idToken: idTokenStr, nonce: nonce)))

        default:
            break
        }
    }

    public func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        "ASAuthorizationAppleIDProvider failed : \(error)".le(T)

        completionHandler?(.failure(AppError(error)))
    }
}

// MARK: - nonce generation
import CryptoKit

extension AppleAuthService {
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    @available(iOS 13, *)
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - FBAuthSerbice
#if FBAuth
import FirebaseAuth

extension AppleAuthService: FBAuthServiceProviding {
    func login(params _: [String: Any]?) async throws -> (AuthCredential, AuthUserInfo) {
        let authContext = try await asyncLogin()
        let credential = OAuthProvider.credential(withProviderID: FBAuthService.AuthType.apple.providerId,
                                                  idToken: authContext.idToken,
                                                  rawNonce: authContext.nonce)
        return (credential, userInfo)
    }
}
#endif
