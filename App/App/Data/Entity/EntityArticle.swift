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
    
    // Basic article information
    var url: String
    var title: String?
    var text: String?
    var language: String?
    var image: String?
    var description: String?
    var summary: String?
    var source: String?
    var author: UUID?
    var mainSubject: String?
    var threadId: Int?
    
    // Sentiment analysis
    var sentiment: Float?
    struct EntitySentiment: Codable {
        let entity: String
        let sentiment: Float
        let reasoning: String?
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
    
    // Entities and keywords
    var entities: [String]?
    var keywords: [String]?
    
    // Structured summary
    var summaryHeadline: String?
    var summaryKeyPoints: [String]?
    
    /* NO need
    // Clustering indicators
    var eventName: String?
    var subjectChain: [String]?
    var semanticAnchors: [String]?
    var clusteringText: String?
    var embeddingInput: String?
    */
    
    // internal use only
    var index: Int?
    
    // Computed property for sentiment enum (backward compatibility)
    var sentimentEnum: EntityArticleSentiment? {
        guard let sentiment = sentiment else { return nil }
        if sentiment > 0.1 { return .positive }
        if sentiment < -0.1 { return .negative }
        return .neutral
    }
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
