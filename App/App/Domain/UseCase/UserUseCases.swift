//
//  UserUseCases.swift
//  App
//
//  Created by Yongsik Kim on 8/6/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum User {
        static func fetch(id: UUID) async throws -> EntityUser {
            let users: [EntityUser]
            do {
                users = try await SupabaseService.shared.fetch(from: BackEnd.Users.fetch(id).query)
            } catch {
                "failed to read user : \(error)".le(T)
                throw error
            }
            guard let user = users.first else {
                "user \(id) not found".le(T)
                throw AppError.notFound()
            }
            return user
        }
    }
}