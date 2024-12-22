//
//  EntityUser.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation

struct EntityUser: Codable {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
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
}

extension EntityUser: Identifiable, Hashable {}
