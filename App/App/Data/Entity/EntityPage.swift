//
//  EntityPage.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation

struct EntityPage: Codable, Identifiable, Equatable {
    var id: Int?
    var createdAt: Date
    var updatedAt: Date
    
    let userId: UUID
    
    var title: String?
    var pictureUrl: String?
    var tags: [String]?
    var isPrivate: Bool
}
