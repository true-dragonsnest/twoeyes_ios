//
//  ExploreView.swift
//  App
//
//  Created by Yongsik Kim on 3/8/25.
//

import SwiftUI

private let T = #fileID

struct ExploreView: View {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    @State var repo: ArticleRepo = .init()
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if repo.articles.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .label3))
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(repo.articles) { article in
                        ArticleCardView(article: article)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .scrollTransition(topLeading: .interactive,
                                              bottomTrailing: .interactive,
                                              axis: .vertical) { view, phase in
                                view.opacity(1 - abs(phase.value * 0.7))
                            }
                    }
                }
                .scrollTargetLayout()
                .padding(.bottom, 36)
            }
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollClipDisabled()
    }
}

