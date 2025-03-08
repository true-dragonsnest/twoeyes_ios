//
//  EntityArticle.swift
//  App
//
//  Created by Yongsik Kim on 3/8/25.
//

import Foundation

struct EntityArticle: Codable {
    var id: Int
    var createdAt: Date
    var updatedAt: Date
    
    var title: String?
    var url: String?
    var image: String?
    var thumbnail: String?
    var description: String?
    var summary: String?
    
    var author: UUID
    
    var source: String?
    var sourceThumbnail: String?
    
    var keywords: [String]?
    var likeKeywords: [String]?
    var hateKeywords: [String]?
}

extension EntityArticle: Identifiable, Hashable {}
