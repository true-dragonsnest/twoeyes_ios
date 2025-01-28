//
//  EntityChat.swift
//  App
//
//  Created by Yongsik Kim on 1/25/25.
//

import Foundation

struct EntityChat: Codable {
    enum Role: String, Codable {
        case user
        case assistant
    }

    var role: Role
    var content: String
}
