//
//  SignupUseCase.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Signup {
        static private func checkDuplication(id: UUID) async -> Bool {
            do {
                let _: EntityUser = try await UseCases.User.fetch(id: id)
                return false
            } catch {
                "user may not exist : \(error)".ld(T)
            }
            return true
        }
        
        static func execute(id: UUID, userId: String, nickname: String?, profilePictureUrl: String?) async throws {
            guard await checkDuplication(id: id) else {
                throw AppError.alreadyExists("user already exists".le(T))
            }
            
            let entity = EntityUser(id: id, createdAt: .now, updatedAt: .now,
                                    userId: userId,
                                    nickname: nickname, profilePictureUrl: profilePictureUrl)
            do {
                guard let query = BackEnd.Users.insert(entity).query else {
                    throw AppError.invalidRequest()
                }
                try await query.execute()
                "user created : \(entity)".ld(T)
            } catch {
                "Failed to create user : \(error)".le(T)
                throw error
            }
        }
    }
}

