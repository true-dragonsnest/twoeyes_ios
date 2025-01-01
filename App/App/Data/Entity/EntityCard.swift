//
//  EntityCard.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation

struct EntityCard: Codable, Identifiable, Equatable {
    var id: Int?
    var createdAt: Date
    var updatedAt: Date
    
    let userId: UUID
    let noteId: Int
     
    var question: String
    var answer: String
    var incorrectAnswers: [String]?
    
    var sttEnabled: Bool
    var isPrivate: Bool
}
