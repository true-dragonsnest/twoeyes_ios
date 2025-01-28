//
//  EntityNote.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

// FIXME: delete this

import Foundation

struct EntityNote: Codable, Identifiable, Equatable {
    var id: Int?
    var createdAt: Date
    var updatedAt: Date
    
    let userId: UUID
    
    enum NoteType: String, Codable, CaseIterable {
        case vocabulary
        case custom
        
        var displayText: String {
            switch self {
            case .vocabulary: "Vocabulary".localized
            case .custom: "Custom".localized
            }
        }
        var symbolName: String {
            switch self {
            case .vocabulary: "translate"
            case .custom: "bubbles.and.sparkles.fill"
            }
        }
    }
    var noteType: NoteType
    
    var title: String?
    var pictureUrl: String?
    var tags: [String]?
    
    var isPrivate: Bool
}
