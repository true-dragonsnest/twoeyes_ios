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
                articles = try await UseCases.Fetch.articles()
            } catch {
                ContentViewModel.shared.error = error
            }
        }
    }
}

