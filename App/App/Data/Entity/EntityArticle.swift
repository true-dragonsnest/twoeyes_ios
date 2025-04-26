//
//  EntityArticle.swift
//  App
//
//  Created by Yongsik Kim on 3/8/25.
//

import SwiftUI

enum EntityArticleSentiment: Int, Codable {
    case positive = 1
    case neutral = 0
    case negative = -1
    
    var icon: String? {
        switch self {
        case .positive: "😀"
        case .negative: "☹️"
        default: nil
        }
    }
    
    var color: Color? {
        switch self {
        case .positive: .green
        case .negative: .red
        default: nil
        }
    }
}

struct EntityArticle: Codable {
    var id: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    var title: String?
    var url: String?
    var image: String?
    
    var author: UUID
    var source: String?
    
    var description: String?
    var summary: String?
    var text: String?
    var language: String?
    
    var mainSubject: String?
    var sentiment: EntityArticleSentiment?
    var threadId: Int?
    
    // internal use only
    var index: Int?
}

extension EntityArticle: Identifiable, Hashable {}
