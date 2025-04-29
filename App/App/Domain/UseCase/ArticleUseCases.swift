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
    
    static func fetchList(from startId: Int? = nil, limit: Int = Const.pageSize) async throws -> [EntityArticle] {
        do {
            let articles: [EntityArticle] = try await SupabaseService.shared.fetch(from: BackEnd.Articles.fetchList(start: startId, limit: limit).query)
            return articles
        } catch {
            "failed to fetch articles : \(error)".le(T)
            throw error
        }
    }
    
    static func post(url: String) async throws -> EntityArticle {
        struct Request: Codable {
            let url: String
        }
        
        do {
            let req = Request(url: url)
            let ret: EntityArticle = try await HttpApiService.shared.post(entity: req,
                                                                          to: BackEnd.Functions.addArticle.url,
                                                                          decoder: BackEnd.Functions.decoder(),
                                                                          encoder: BackEnd.Functions.encoder())
            "article added : \(o: ret.jsonPrettyPrinted)".ld(T)
            return ret
        } catch {
            "failed to post article : \(error)".le(T)
            throw error
        }
    }
}
