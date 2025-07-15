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
    
    init?(from floatValue: Float) {
        if floatValue >= 0.1 {
            self = .positive
        } else if floatValue <= -0.1 {
            self = .negative
        } else {
            self = .neutral
        }
    }
}

struct EntityArticle: Codable {
    var id: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    var url: String
    var source: String?
    var author: UUID?
    
    var title: String?
    var text: String?
    var language: String?
    var image: String?
    var description: String?
    var summary: String?
    var mainSubject: String?
    
    var threadId: Int?
    var entities: [String]?
    
    var sentiment: Float?
    struct EntitySentiment: Codable {
        let entity: String
        let sentiment: Float
        let reasoning: String?
        
        var sentimentEnum: EntityArticleSentiment? {
            EntityArticleSentiment(from: sentiment)
        }
    }
    var sentimentEntitySpecific: [EntitySentiment]?
    var sentimentReasoning: String?
    
    // Categories
    enum PrimaryCategory: String, Codable {
        case politics = "Politics"
        case economy = "Economy"
        case society = "Society"
        case international = "International"
        case culture = "Culture"
        case sports = "Sports"
        case tech = "Technology/Science"
        case life = "Life/Health"
        case environment = "Environment"
        case unknown
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let stringValue = try container.decode(String.self)
            self = PrimaryCategory(rawValue: stringValue) ?? .unknown
        }
    }
    var primaryCategory: PrimaryCategory?
    var secondaryCategory: String?
    
    var keywords: [String]?
    var keyPoints: [String]?
    
    var sentimentEnum: EntityArticleSentiment? {
        guard let sentiment else { return nil }
        return EntityArticleSentiment(from: sentiment)
    }
    
    // internal use only
    var index: Int?
}

extension EntityArticle: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(url)
    }
    
    static func == (lhs: EntityArticle, rhs: EntityArticle) -> Bool {
        lhs.id == rhs.id && lhs.url == rhs.url
    }
}
