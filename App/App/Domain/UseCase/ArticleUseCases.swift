//
//  ArticleUseCases.swift
//  App
//
//  Created by Yongsik Kim on 4/25/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Articles {}
}

extension UseCases.Articles {
    enum Const {
        static let pageSize: Int = 10
    }
    
    static func fetch(from startId: Int? = nil, limit: Int = Const.pageSize) async throws -> [EntityArticle] {
        do {
            let articles: [EntityArticle] = try await SupabaseService.shared.fetch(from: BackEnd.Articles.fetch(start: startId, limit: limit).query)
            return articles
        } catch {
            "failed to fetch articles : \(error)".le(T)
            throw error
        }
    }
    
    static func add(_ entity: EntityArticle) async throws {
    }
}
