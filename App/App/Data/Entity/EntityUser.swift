//
//  EntityUser.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation

struct EntityUser: Codable {
    var id: UUID
    
    var userId: String
    var nickname: String?
    
    enum Gender: String, Codable {
        case female
        case male
        case nonBinary
        case neutral
    }
    var gender: Gender?
    
    var profilePictureUrl: String?
    var lastComment: String?
    
    var createdAt: Date?
    var updatedAt: Date?
}

extension EntityUser: Identifiable, Hashable {}
