//
//  LoginUserModel.swift
//  App
//
//  Created by Yongsik Kim on 1/1/25.
//

import SwiftUI

private let T = #fileID

@Observable
class LoginUserModel {
    static let shared = LoginUserModel()
    
    var user: EntityUser?
    
    func login(userId: UUID) async throws -> Bool {
        do {
            let entity: EntityUser = try await UseCases.User.fetch(id: userId)
            "login user : \(entity.jsonPrettyPrinted)".ld(T)
            await MainActor.run {
                user = entity
            }
        } catch {
            let appError = AppError(error)
            if case .notFound = appError {
                "user not found : \(error)".le(T)
                return false
            }
            "failed to fetch user : \(error)".le(T)
            throw error
        }
        return true
    }
    
    func logout() async throws {
        do {
            try await SupabaseService.shared.signOut()
            await MainActor.run {
                user = nil
            }
        } catch {
            "failed to sign out : \(error)".le(T)
            throw error
        }
    }
}
