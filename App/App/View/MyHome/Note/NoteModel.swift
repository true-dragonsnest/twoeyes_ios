//
//  NoteModel.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

@Observable
class NoteModel {
    var image: UIImage?
    var title: String = ""
    var tags: [String] = []
    var isPrivate = false
    
    var cards: [EntityCard] = []
    
    var isEditMode = false
    var readyToSave = true
    
    init() {
    }
    
    convenience init(from entity: EntityNote) {
        self.init()
        // FIXME: code here
    }
}
