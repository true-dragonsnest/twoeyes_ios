//
//  ParseGenResultUseCases.swift
//  App
//
//  Created by Yongsik Kim on 1/2/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum ParseGenResult {
    }
}

// MARK: - word card
extension UseCases.ParseGenResult {
    enum WordCard {
        struct Response: Codable {
            var question: String
            var answer: String
            struct Example: Codable {
                var sentence: String
                var translation: String
            }
            var examples: [Example]
        }
        
        static func parse(userId: UUID, response jsonStr: String) throws -> [EntityCard] {
            do {
                guard let parsed: [Response] = try [Response].decode(fromJsonStr: jsonStr) else {
                    throw AppError.invalidResponse("invalid AI response: \(jsonStr)".le())
                }
                "wordcard : \(o: parsed.jsonPrettyPrinted)".li()
                
                let cards = parsed.map { item in
                    EntityCard(createdAt: .now,
                               updatedAt: .now,
                               userId: userId,
                               noteId: 0,
                               question: item.question,
                               answer: item.answer,
                               sentenceExamples: item.examples.map { .init(sentence: $0.sentence, translation: $0.translation) },
                               sttEnabled: true,
                               isPrivate: false)
                }
                return cards
            } catch {
                "failed to parse wordcard : \(error)".le()
                throw error
            }
        }
    }
}

// MARK: - custom card
extension UseCases.ParseGenResult {
    enum CustomCard {
        struct Response: Codable {
            var question: String
            var answer: String
        }
        
        static func parse(userId: UUID, response jsonStr: String) throws -> [EntityCard] {
            do {
                guard let parsed: [Response] = try [Response].decode(fromJsonStr: jsonStr) else {
                    throw AppError.invalidResponse("invalid AI response: \(jsonStr)".le())
                }
                "custom card : \(o: parsed.jsonPrettyPrinted)".li()
                
                let cards = parsed.map { item in
                    EntityCard(createdAt: .now,
                               updatedAt: .now,
                               userId: userId,
                               noteId: 0,
                               question: item.question,
                               answer: item.answer,
                               sttEnabled: true,
                               isPrivate: false)
                }
                return cards
            } catch {
                "failed to parse customcard : \(error)".le()
                throw error
            }
        }

    }
}
