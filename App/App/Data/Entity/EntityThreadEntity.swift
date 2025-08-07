//
//  EntityThreadEntity.swift
//  App
//
//  Created by Yongsik Kim on 8/7/25.
//

import Foundation

struct EntityThreadEntity: Codable, Identifiable, Equatable {
    var id: Int?
    var threadId: Int
    var entityName: String
    var sentimentSum: Double?
    var sentimentCount: Int?
    var averageSentiment: Double?
    var firstSeenAt: Date?
    var lastUpdatedAt: Date?
}