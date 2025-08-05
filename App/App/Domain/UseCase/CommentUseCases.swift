//
//  CommentUseCases.swift
//  App
//
//  Created by Yongsik Kim on 8/4/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Comment {}
}

// MARK: - Request Models
extension UseCases.Comment {
    struct AddCommentRequest: Codable {
        let threadId: Int
        let content: String?
        let userSentiment: Double?
        let mentions: CommentMentions?
        let aiGeneration: AIGenerationOptions?
        let languageCode: String?
    }

    struct CommentMentions: Codable {
        let articleIds: [Int]?
        let userIds: [String]?
        let commentIds: [String]?
    }

    struct AIGenerationOptions: Codable {
        let targetSentiment: Double?
        let context: String?
    }

    struct GetThreadCommentsRequest: Codable {
        let threadId: Int
        let limit: Int?
        let offset: Int?
        let sortBy: String?
        let sortOrder: String?
    }

    struct UpdateCommentRequest: Codable {
        let commentId: String
        let content: String?
        let userSentiment: Double?
        let mentions: CommentMentions?
    }

    struct DeleteCommentRequest: Codable {
        let commentId: String
    }
}

// MARK: - Response Models
extension UseCases.Comment {
    struct AddCommentResponse: Codable {
        let success: Bool
        let comment: EntityComment
        let sentimentAnalysis: SentimentAnalysis?
    }

    struct SentimentAnalysis: Codable {
        let sentiment: Double
        let confidence: Double
        let reasoning: String
    }

    struct GetThreadCommentsResponse: Codable {
        let comments: [EntityComment]
        let total: Int
        let nextOffset: Int?
    }

    struct UpdateCommentResponse: Codable {
        let success: Bool
        let comment: EntityComment
    }

    struct DeleteCommentResponse: Codable {
        let success: Bool
        let message: String
    }
}

// MARK: - API Functions
extension UseCases.Comment {
    static func addComment(
        threadId: Int,
        content: String? = nil,
        userSentiment: Double? = nil,
        mentions: CommentMentions? = nil,
        aiGeneration: AIGenerationOptions? = nil,
        languageCode: String? = nil
    ) async throws -> AddCommentResponse {
        let request = AddCommentRequest(
            threadId: threadId,
            content: content,
            userSentiment: userSentiment,
            mentions: mentions,
            aiGeneration: aiGeneration,
            languageCode: languageCode
        )
        
        do {
            let decoder = BackEnd.Functions.decoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let encoder = BackEnd.Functions.encoder()
            
            let response: AddCommentResponse = try await HttpApiService.shared.post(
                entity: request,
                to: BackEnd.Functions.addComment.url,
                decoder: decoder,
                encoder: encoder,
                logLevel: 2
            )
            "comment added : \(o: response.jsonPrettyPrinted)".ld(T)
            return response
        } catch {
            "failed to add comment : \(error)".le(T)
            throw error
        }
    }
    
    static func getThreadComments(
        threadId: Int,
        limit: Int? = nil,
        offset: Int? = nil,
        sortBy: String? = nil,
        sortOrder: String? = nil
    ) async throws -> GetThreadCommentsResponse {
        let request = GetThreadCommentsRequest(
            threadId: threadId,
            limit: limit,
            offset: offset,
            sortBy: sortBy,
            sortOrder: sortOrder
        )
        
        do {
            let decoder = BackEnd.Functions.decoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let encoder = BackEnd.Functions.encoder()
            
            let response: GetThreadCommentsResponse = try await HttpApiService.shared.post(
                entity: request,
                to: BackEnd.Functions.getThreadComments.url,
                decoder: decoder,
                encoder: encoder,
                logLevel: 2
            )
            "fetched \(response.comments.count) comments".ld(T)
            return response
        } catch {
            "failed to get thread comments : \(error)".le(T)
            throw error
        }
    }
    
    static func updateComment(
        commentId: String,
        content: String? = nil,
        userSentiment: Double? = nil,
        mentions: CommentMentions? = nil
    ) async throws -> UpdateCommentResponse {
        let request = UpdateCommentRequest(
            commentId: commentId,
            content: content,
            userSentiment: userSentiment,
            mentions: mentions
        )
        
        do {
            let decoder = BackEnd.Functions.decoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let encoder = BackEnd.Functions.encoder()
            
            let response: UpdateCommentResponse = try await HttpApiService.shared.post(
                entity: request,
                to: BackEnd.Functions.updateComment.url,
                decoder: decoder,
                encoder: encoder,
                logLevel: 2
            )
            "comment updated : \(o: response.jsonPrettyPrinted)".ld(T)
            return response
        } catch {
            "failed to update comment : \(error)".le(T)
            throw error
        }
    }
    
    static func deleteComment(commentId: String) async throws -> DeleteCommentResponse {
        let request = DeleteCommentRequest(commentId: commentId)
        
        do {
            let decoder = BackEnd.Functions.decoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let encoder = BackEnd.Functions.encoder()
            
            let response: DeleteCommentResponse = try await HttpApiService.shared.post(
                entity: request,
                to: BackEnd.Functions.deleteComment.url,
                decoder: decoder,
                encoder: encoder,
                logLevel: 2
            )
            "comment deleted : \(o: response.jsonPrettyPrinted)".ld(T)
            return response
        } catch {
            "failed to delete comment : \(error)".le(T)
            throw error
        }
    }
}
