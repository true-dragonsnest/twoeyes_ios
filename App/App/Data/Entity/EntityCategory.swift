//
//  EntityCategory.swift
//  App
//
//  Created by Yongsik Kim on 8/15/25.
//

import Foundation

struct EntityCategory: Codable, Identifiable {
    let original: String
    let translated: String?
    
    var id: String? { original }
}
