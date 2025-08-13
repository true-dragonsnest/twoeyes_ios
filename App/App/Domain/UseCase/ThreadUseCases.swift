//
//  ThreadUseCases.swift
//  App
//
//  Created by Yongsik Kim on 4/29/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Threads {}
}

extension UseCases.Threads {
    enum Const {
        static let pageSize: Int = 10
    }
    
    static func fetchList(from startId: Int? = nil, limit: Int = Const.pageSize) async throws -> [EntityThread] {
        do {
            let threads: [EntityThread] = try await SupabaseService.shared.fetch(from: BackEnd.Threads.fetchList(start: startId, limit: limit).query)
            return threads
        } catch {
            "failed to fetch threads : \(error)".le(T)
            throw error
        }
    }
    
    static func fetch(threadId: Int) async throws -> EntityThread {
        do {
            let thread: EntityThread = try await SupabaseService.shared.fetch(from: BackEnd.Threads.fetch(threadId: threadId).query)
            return thread
        } catch {
            "failed to fetch thread \(threadId) : \(error)".le(T)
            throw error
        }
    }

    static func findSimilar(to articleId: Int) async throws -> [EntityThread] {
        struct Request: Codable {
            let articleId: Int
            var similarityThreshold = 0.5
            var limit = 10
        }
        
        struct Response: Codable {
            let success: Bool
            let threads: [EntityThread]
        }
        
        do {
            let decoder = BackEnd.Functions.decoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let encoder = BackEnd.Functions.encoder()
            
            let req = Request(articleId: articleId)
            let ret: Response = try await HttpApiService.shared.post(entity: req,
                                                                     to: BackEnd.Functions.findSimilarThreads.url,
                                                                     decoder: decoder,
                                                                     encoder: encoder,
                                                                     logLevel: 1)
            "similar threads : \(o: ret.jsonPrettyPrinted)".ld(T)
            guard ret.success else {
                "find similar threads failed".le(T)
                throw AppError.invalidResponse()
            }
            return ret.threads
        } catch {
            "failed to find similar threads : \(error)".le(T)
            throw error
        }
    }
    
    /// returns `threadId`
    static func addArticle(articleId: Int, to threadId: Int?) async throws -> Int {
        struct Request: Codable {
            let articleId: Int
            let threadId: Int?
            var createNewIfNeeded: Bool = true
        }
        
        struct Response: Codable {
            let success: Bool
            let threadId: Int
            let created: Bool
            let message: String?
        }
        
        do {
            let decoder = BackEnd.Functions.decoder()
            let encoder = BackEnd.Functions.encoder()
            
            let req = Request(articleId: articleId, threadId: threadId)
            let ret: Response = try await HttpApiService.shared.post(entity: req,
                                                                     to: BackEnd.Functions.addArticleToThread.url,
                                                                     decoder: decoder,
                                                                     encoder: encoder,
                                                                     logLevel: 1)
            "add to thread : \(ret.threadId), created = \(ret.created), msg = \(o: ret.message)".ld(T)
            guard ret.success else {
                "add to threads failed".le(T)
                throw AppError.invalidResponse()
            }
            return ret.threadId
        } catch {
            "failed to add to thread : \(error)".le(T)
            throw error
        }
    }
    
    static func fetchThreadEntities(threadId: Int) async throws -> [EntityThreadEntity] {
        do {
            let entities: [EntityThreadEntity] = try await SupabaseService.shared.fetch(from: BackEnd.ThreadEntities.fetchForThread(threadId: threadId).query)
            return entities
        } catch {
            "failed to fetch thread entities for thread \(threadId) : \(error)".le(T)
            throw error
        }
    }
}
