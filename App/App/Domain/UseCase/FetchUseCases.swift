//
//  FetchUseCases.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Fetch {
        static func intro() async throws -> EntityIntro {
            let intros: [EntityIntro]
            do {
                intros = try await SupabaseService.shared.fetch(from: BackEnd.Intro.fetch.query)
            } catch {
                "failed to read intro : \(error)".le(T)
                throw error
            }
            //"intros : \(o: intros.jsonPrettyPrinted)".ld(T)
            guard let intro = intros.first else {
                "no intro fetched".lf(T)
                throw AppError.notFound()
            }
            return intro
        }
        
        static func user(id: UUID) async throws -> EntityUser {
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
        
        static func articles() async throws -> [EntityArticle] {
            do {
                let articles: [EntityArticle] = try await SupabaseService.shared.fetch(from: BackEnd.Articles.fetch.query)
                return articles
            } catch {
                "failed to fetch articles : \(error)".le(T)
                throw error
            }
        }
    }
}

