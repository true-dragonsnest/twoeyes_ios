//
//  EntityThread.swift
//  App
//
//  Created by Yongsik Kim on 4/29/25.
//

import Foundation

struct EntityThread: Codable, Identifiable, Equatable {
    var id: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    var title: String?
    var mainSubject: String
    
    var images: [String]?
    
    let similarity: Double?     // only in find similar thread response
}
