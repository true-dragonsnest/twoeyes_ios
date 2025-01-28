//
//  EntityCard.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

// FIXME: delete this

import Foundation

struct EntityCard: Codable, Identifiable, Equatable {
    var id: Int?
    var createdAt: Date
    var updatedAt: Date
    
    let userId: UUID
    var noteId: Int
    
    var question: String
    var answer: String
    
    struct SentenceExample: Codable, Equatable {
        let sentence: String
        let translation: String
    }
    var sentenceExamples: [SentenceExample]?  // wordCard
    
    var sttEnabled: Bool
    var isPrivate: Bool
}
