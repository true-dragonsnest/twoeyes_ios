//
//  ArticleRepo.swift
//  App
//
//  Created by Yongsik Kim on 3/9/25.
//

import SwiftUI

private let T = #fileID

@Observable
class ArticleRepo {
    var articles: [EntityArticle] = []
    
    init() {
        "init".li(T)
        fetch()
    }
    
    func fetch() {
        Task { @MainActor in
            do {
                let articles = try await UseCases.Fetch.articles()
                self.articles = (0..<articles.count).map { i in
                    var updated = articles[i]
                    updated.index = i
                    return updated
                }
            } catch {
                ContentViewModel.shared.error = error
            }
        }
    }
}

