//
//  GptApiUseCases.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation
/*
extension UseCases {
    enum GptApiCall {
        static let apiUrl: String = "https://api.openai.com/v1/chat/completions"
        
        struct Content: Codable {
            var keyword: String
            var strength: Double
            var sentiment: Int
        }

        
        static let systemPrompt =
            """
            Identify five topics mentioned in the news text given by user.

            - Limit each item to one or two words.
            - Rate the strength of each item on a scale from 0 (weakest) to 1 (strongest).
            - Assess the sentiment associated with each item.

            write your response in JSON format not markdown style with properties:
            keyword: string,
            strength: double,
            sentiment: 1 (positive), 0 (neutral), -1(negative)
            """
        
        struct EntityRequestGpt: Codable {
            struct Message: Codable {
                enum Role: String, Codable {
                    case system
                    case user
                    case assistant
                }

                var role: Role
                var content: String
            }

            var model: String = "gpt-4o-mini"
            var messages: [Message]
            var temperature: Double = 0.1
        }
        
        struct EntityResponseGpt: Codable {
            struct Choices: Codable {
                var index: Int
                var message: ResultMessage
                var finish_reason: String
            }

            struct ResultMessage: Codable {
                var role: String
                var content: String
//                var content: [EntityContent]
            }

            var id: String
            var object: String
            var model: String
            var created: Int32

            var choices: [Choices]
        }

        
        static func execute(_ article: String) async throws -> [EntityContent] {
            
            let userMsg = EntityRequestGpt.Message(role: .user, content: article)
            let systemMsg = EntityRequestGpt.Message(role: .system, content: systemPrompt)
            let request = EntityRequestGpt(messages: [userMsg, systemMsg])
    
            let response: EntityResponseGpt = try await HttpService.shared.post(request, from: AppUrl.GptApiUrl)
            guard let content: String = response.choices[safe: 0]?.message.content else { throw TwoEyesError.generalError("")}

            guard let data = content.data(using: .utf8) else { throw TwoEyesError.generalError("") }
            
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode([EntityContent].self, from: data)
                "content: \(result)".ld()
                return result
            } catch {
                throw TwoEyesError(error)
            }
        
        }

    }
}

*/
