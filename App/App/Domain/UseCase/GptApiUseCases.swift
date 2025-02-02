//
//  GptCallUseCases.swift
//  TwoEyes
//
//  Created by Eunhye Kim on 10/6/24.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Gpt {
        static let model = "gpt-4o-mini"

        private struct Message: Codable {
            enum Role: String, Codable {
                case system
                case user
                case assistant
            }

            var role: Role
            var content: String
        }
        
        private struct Request: Codable {
            var model: String
            var messages: [Message]
            var temperature: Double
            var topP: Double
            var maxCompletionTokens: Double
        }
        
        private struct Response: Codable {
            struct Choices: Codable {
                let index: Int?
                let message: Message
                let finishReason: String?
            }
            
            struct Usage: Codable {
                let promptTokens: Int?
                let completionTokens: Int?
                let totalTokens: Int?
                struct PromptTokensDetail: Codable {
                    let cachedTokens: Int?
                    let audioTokens: Int?
                }
            }

            let id: String
            let object: String?
            let model: String
            let created: Int32?

            let choices: [Choices]
            let usage: Usage?
        }
        
        static func completeChat(
            systemPrompt: String,
            chats: [EntityChat],
            temperature: Double = 0.9,
            topP: Double = 1,
            maxTokens: Double = 2048
        ) async throws -> String {
            let messages = chats.map { Message(role: $0.role == .assistant ? .assistant : .user, content: $0.message) }
            let systemMsg = Message(role: .system, content: systemPrompt)
            let request = Request(model: model,
                                  messages: [systemMsg] + messages,
                                  temperature: temperature,
                                  topP: topP,
                                  maxCompletionTokens: maxTokens)
    
            let http = HttpApiService()
            await http.setCommomHeader(forKey: "Authorization", value: AppKey.gptAuthKey)
            let response: Response = try await http.post(entity: request, to: "https://api.openai.com/v1/chat/completions", logLevel: 2)
            guard let content: String = response.choices[safe: 0]?.message.content else {
                throw AppError.invalidResponse("invalid response : \(response)".le(T) )
            }
            "response : \(content), usage : \(o: response.usage.jsonPrettyPrinted)".ld(T)
            
            return content
        }

    }
}
