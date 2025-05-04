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
        }
        
        struct Response: Codable {
            struct Thread: Codable {
                // same as EntityThread
                var id: Int?
                var createdAt: Date?
                var updatedAt: Date?
                
                var title: String?
                var mainSubject: String
                
                var images: [String]?
                var articleIds: [Int]?
                //
                
                let similarity: Double?
                
                func mapToEntityThread() -> EntityThread {
                    return EntityThread(id: id,
                                        createdAt: createdAt,
                                        updatedAt: updatedAt,
                                        title: title,
                                        mainSubject: mainSubject,
                                        images: images,
                                        articleIds: articleIds)
                }
            }
            
            let success: Bool
            let threads: [Thread]
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
                                                                       logLevel: 2)
            "similar threads : \(o: ret.jsonPrettyPrinted)".ld(T)
            guard ret.success else {
                "find similar threads failed".le(T)
                throw AppError.invalidResponse()
            }
            return ret.threads.map { $0.mapToEntityThread() }
        } catch {
            "failed to find similar threads : \(error)".le(T)
            throw error
        }
    }
}
