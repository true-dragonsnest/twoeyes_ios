//
//  SupabaseService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 5/4/24.
//

import Foundation
import Supabase
import Combine

private let T = #fileID

public actor SupabaseService {
    public struct Config {
        let projectUrl: String
        let apiKey: String
        public init(projectUrl: String, apiKey: String) {
            self.projectUrl = projectUrl
            self.apiKey = apiKey
        }
    }
    private static var config: Config?
    public static func setup(_ config: Config) async throws {
        Self.config = config
        try await shared.setup()
    }
    
    public static let shared = SupabaseService()
    private init() {}
    
    func setup() throws {
        do {
            try initSDKIfNeeded()
            initAuthService()
        } catch {
            "failed to init Supabase service : \(error)".le(T)
            throw error
        }
    }
    
    nonisolated public var client: SupabaseClient? {
        clientPub.value
    }
    public let clientPub = CurrentValueSubject<SupabaseClient?, Never>(nil)
    
    nonisolated static public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .init(secondsFromGMT: 0)
        //formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    nonisolated public lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .formatted(Self.dateFormatter)
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    nonisolated public lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        //decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .formatted(Self.dateFormatter)
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private func initSDKIfNeeded() throws {
        guard client == nil else {
            "already inited".le(T)
            return
        }
        guard let config = Self.config else {
            throw AppError.notInited("no config".lf(T))
        }
        guard let projectUrl = URL(string: config.projectUrl) else {
            throw AppError.invalidRequest("invalid project URL : \(config.projectUrl)".le(T))
        }
        
        clientPub.send(SupabaseClient(supabaseURL: projectUrl, supabaseKey: config.apiKey))
        "Supabase inited".ld(T)
    }
    
    public func fetch<M: Codable>(from query: PostgrestBuilder?, logLevel: Int = 0) async throws -> M {
        guard let query else {
            throw AppError.invalidRequest("nil fetch query".le(T))
        }
        do {
            let data = try await query.execute().data
            do {
                let ret: M = try decoder.decode(M.self, from: data)
                if logLevel > 1 {
                    "FETCH : \(o: ret.jsonPrettyPrinted)".ld(T)
                }
                return ret
            } catch {
                "failed to decode fetch response : \(error), \(o: String(data: data, encoding: .utf8))".le(T)
                throw error
            }
        } catch {
            "failed to fetch : \(error)".le(T)
            throw error
        }
    }
    
    public func observeTable(name: String, 
                             as channelName: String,
                             filter: String?) async throws -> (channel: RealtimeChannelV2, stream: AsyncStream<AnyAction>) {
        guard let client else {
            throw AppError.notInited()
        }
        let channel = await client.channel(channelName)
        let changeStream = await channel.postgresChange(AnyAction.self, schema: "public", table: name, filter: filter)
        
        "starting observation to \(name) as channel \(channelName)".ld(T)
        await channel.subscribe()
        
        return (channel: channel, stream: changeStream)
    }
        
    // MARK: - auth
    public typealias AuthToken = String
    public typealias AuthUser = User
    public enum AuthState {
        case signIn(user: AuthUser)
        case signOut
    }
    nonisolated public var authState: AuthState {
        authStatePub.value
    }
    public let authStatePub = CurrentValueSubject<AuthState, Never>(.signOut)
    
    
    nonisolated public var authToken: String? {
        authTokenPub.value
    }
    public let authTokenPub = CurrentValueSubject<AuthToken?, Never>(nil)
    
    public private(set) var session: Session?
    
    nonisolated public var authUser: AuthUser? {
        authUserPub.value
    }
    public let authUserPub = CurrentValueSubject<AuthUser?, Never>(nil)
    
    private func initAuthService() {
        guard let client else {
            "not inited".lf(T)
            return
        }
        
        Task {
            for await(event, session) in client.auth.authStateChanges {
                "auth event : \(event), \(o: session)".ld(T)
                switch event {
                case .initialSession:
                    if session == nil { break }
                    fallthrough
                case .signedIn:
                    guard let user = session?.user,
                          let authToken = session?.accessToken
                    else {
                        "invalid session during sign in".le(T)
                        return
                    }
                    if case .signIn(_) = authState, let prevUser = authUser {
                        "already signed in : \(prevUser.id) vs \(user.id)".le(T)
                        if prevUser.id == user.id {
                            "duplicated sign in event".le(T)
                            return
                        }
                        "sign in conflict. abort auth session".le(T)
                        try? await signOut()
                        return
                    }
                    
                    "sign in as \(user)".ld(T)
                    authTokenPub.send(authToken)
                    authUserPub.send(user)
                    authStatePub.send(.signIn(user: user))
                    
                case .signedOut:
                    if case .signOut = authState {
                        "already signout".le(T)
                        return
                    }
                    "sign out".ld(T)
                    authStatePub.send(.signOut)
                    
                case .tokenRefreshed:
                    guard let user = session?.user,
                          let authToken = session?.accessToken else {
                        "invalid session at token refreshed event".le(T)
                        return
                    }
                    "token refreshed : \(o: session), \(authToken)".ld(T)
                    authTokenPub.send(authToken)
                    if case .signIn(_) = authState {
                    } else {
                        "not signed yet. sign in now".ld(T)
                        authUserPub.send(user)
                        authStatePub.send(.signIn(user: user))
                    }
                    
                case .userUpdated:
                    guard let user = session?.user else {
                        "invalid session during user update event".le(T)
                        return
                    }
                    guard case .signIn(_) = authState else {
                        "user updated during not signed in".le(T)
                        return
                    }
                    "user updated : \(user)".ld(T)
                    authUserPub.send(user)
                    
                case .userDeleted:
                    if case .signOut = authState {}
                    else {
                        "user deleted during not signed out".le(T)
                        try? await signOut()
                        authStatePub.send(.signOut)
                    }
                    "user deleted".ld(T)
                    authUserPub.send(nil)
                    
                default:
                    "not handled".lf(T)
                }
            }
            
            "end of auth event observation".ld(T)
        }
    }
    
    public func signInApple() async throws {
        guard let client else { throw AppError.notInited("not inited".lf(T)) }
        
        let context = try await AppleAuthService.shared.asyncLogin()
        do {
            let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, 
                                                                                     idToken: context.idToken,
                                                                                     nonce: context.nonce))
            self.session = session
            "sign in apple ok".ld(T)
        } catch {
            throw AppError.generalError("failed to sign in apple : \(error)".le(T))
        }
    }
    
    public func signInGoogle() async throws {
        guard let client else { throw AppError.notInited("not inited".lf(T)) }
        
        let tokens = try await GoogleAuthService.shared.asyncLogin()
        do {
            let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .google,
                                                                                     idToken: tokens.idToken))
            self.session = session
            "sign in google ok".ld(T)
        } catch {
            throw AppError.generalError("failed to sign in google : \(error)".le(T))
        }
    }
    
    public func signOut() async throws {
        guard let client else { throw AppError.notInited("not inited".lf(T)) }
        
        do {
            try await client.auth.signOut()
            "sign out OK".ld(T)
        } catch {
            throw AppError.generalError("failed to sign out".le(T))
        }
    }
}

// MARK: - Date extension
public extension Date {
    var supabaseStr: String {
        SupabaseService.dateFormatter.string(from: self)
    }
}

// MARK: - Codable mapping
public extension Decodable {
    static func map(from supabaseDict: [String: AnyJSON]) -> Self? {
        var dict = supabaseDict.mapValues(\.value)
        if let val = supabaseDict["createdAt"]?.stringValue, let date = SupabaseService.dateFormatter.date(from: val) {
            dict["createdAt"] = date.timeIntervalSince1970 * 1000
        }
        if let val = supabaseDict["updatedAt"]?.stringValue, let date = SupabaseService.dateFormatter.date(from: val) {
            dict["updatedAt"] = date.timeIntervalSince1970 * 1000
        }
        do {
            let entity: Self = try Self.decode(fromJsonDic: dict, decoder: SupabaseService.shared.decoder)
            return entity
        } catch {
            "Failed to decode Supabase dictionary : \(error)".le(T)
            return nil
        }
    }
}
