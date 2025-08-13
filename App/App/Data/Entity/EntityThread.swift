//
//  EntityThread.swift
//  App
//
//  Created by Yongsik Kim on 4/29/25.
//

import Foundation

struct EntityArticleSnapshot: Codable, Identifiable, Equatable {
    var id: Int { articleId }
    let articleId: Int
    let source: String?
    let title: String?
    let image: String?
}

struct EntityThread: Codable, Identifiable, Equatable {
    var id: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    var title: String?
    var mainSubject: String
    
    var articleSnapshots: [EntityArticleSnapshot]?
    
    let similarity: Double?     // only in find similar thread response
}
