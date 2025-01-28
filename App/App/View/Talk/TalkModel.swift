//
//  TalkModel.swift
//  App
//
//  Created by Yongsik Kim on 1/28/25.
//

import SwiftUI

@Observable
class TalkModel {
    var chats: [EntityChat] = [
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
        .init(role: .assistant, content: "Generative media platform for developers"),
        .init(role: .user, content: "Generative media platform for developers"),
    ]
    
    var chatSuggestions: [String] = []
}
