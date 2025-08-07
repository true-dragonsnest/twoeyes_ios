//
//  ThreadView.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI
import Kingfisher

struct ThreadView: View {
    @Environment(\.sceneSize) var sceneSize
    
    let thread: EntityThread
    
    @State var commentSending = false
    @State private var selectedArticleIndex: Int = 0
    
    private let repository = ThreadRepository.shared
    
    // TODO: Calculate actual safe area + navigation bar height
    private var topGradientHeight: CGFloat {
        120
    }
    
    var comments: [EntityComment] {
        guard let threadId = thread.id else { return [] }
        return repository.threadComments[threadId] ?? []
    }
    
    var articles: [EntityArticle] {
        guard let threadId = thread.id else { return [] }
        return repository.threadArticles[threadId] ?? []
    }
    
    var threadEntities: [EntityThreadEntity] {
        guard let threadId = thread.id else { return [] }
        return repository.threadEntities[threadId] ?? []
    }
    
    var isLoadingComments: Bool {
        guard let threadId = thread.id else { return false }
        return repository.isLoadingComments[threadId] ?? false
    }
    
    var currentArticle: EntityArticle? {
        guard selectedArticleIndex < articles.count else { return nil }
        return articles[selectedArticleIndex]
    }
    
    // MARK: comment input
    @FocusState var focused
    var commentInput: some View {
        InputBar(text: "Drop a comment",
                 focused: $focused,
                 sendEnabled: commentSending == false)
        { comment, commentAttachments in
            Task { @MainActor in
                guard let threadId = thread.id else { return }
                
                withAnimation {
                    commentSending = true
                }
                do {
                    try await repository.addComment(to: threadId, content: comment)
                } catch {
                    ContentViewModel.shared.setError(error)
                }
                withAnimation {
                    commentSending = false
                }
            }
        }
    }
    
    var body: some View {
        content
            .ignoresSafeArea()
//            .navigationTitle("")
//            .toolbarRole(.editor)
//            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                loadInitialData()
            }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: sceneSize.width)
                
                LazyVStack(spacing: Spacing.m) {
                    ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                        ArticleCard(article: article, isSelected: index == selectedArticleIndex)
                            .id(index)
                            .onAppear {
                                withAnimation {
                                    selectedArticleIndex = index
                                }
                            }
                            .padding(.horizontal, Padding.horizontal)
                    }
                }
                .padding(.vertical, Padding.m)
            }
        }
        .mask(alignment: .top) {
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: Color.white.opacity(0), location: 0.0),
                            .init(color: Color.white.opacity(0.1), location: 0.95),
                            .init(color: Color.white, location: 1.0)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: sceneSize.width, height: sceneSize.width)
                
                Color.white
            }
        }
        .background(alignment: .top) {
            backgroundImage
                .overlay(alignment: .bottom) {
                    threadHeader
                        .padding(.horizontal, Padding.horizontal)
                        .padding(.bottom, Padding.l)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0),
                                    Color.black.opacity(0.5),
                                    Color.black
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
        }
        .background(.black)
    }

    //        .overlay(alignment: .bottom) {
//            commentInput
//                .padding(Padding.m)
//                .background(
//                    Color.black
//                        .opacity(0.8)
//                        .background(.ultraThinMaterial)
//                        .ignoresSafeArea(edges: .bottom)
//                )
//        }

    
    @ViewBuilder
    var backgroundImage: some View {
        Group {
            if let url = URL(fromString: currentArticle?.image ?? articles.first?.image) {
                KFImage(url)
                    .backgroundDecode(true)
                    .resizable()
                    .placeholder {
                        Color.secondaryFill
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: sceneSize.width, height: sceneSize.width)
                    .clipped()
            } else {
                Color.secondaryFill
            }
        }
        .frame(width: sceneSize.width, height: sceneSize.width)
        .overlay(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: topGradientHeight)
        }
    }
    
    @ViewBuilder
    var threadHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
//            if let category = thread.category {
//                Text(category)
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.white.opacity(0.8))
//                    .padding(.horizontal, Padding.s)
//                    .padding(.vertical, 4)
//                    .background(Color.blue)
//                    .clipShape(RoundedRectangle(cornerRadius: 4))
//            }
            
            Text(thread.mainSubject ?? thread.title ?? "Thread")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
//            if let summary = thread.summary {
//                Text(summary)
//                    .font(.subheadline)
//                    .foregroundStyle(.white.opacity(0.9))
//                    .lineLimit(3)
//            }
            
//            HStack(spacing: Spacing.m) {
//                if let createdAt = thread.createdAt {
//                    Label(createdAt.timeAgo(), systemImage: "clock")
//                        .font(.caption)
//                        .foregroundStyle(.white.opacity(0.7))
//                }
                
//                if let articleCount = thread.articleCount {
//                    Label("\(articleCount) articles", systemImage: "doc.text")
//                        .font(.caption)
//                        .foregroundStyle(.white.opacity(0.7))
//                }
//            }
        }
    }
    
    struct ArticleCard: View {
        let article: EntityArticle
        let isSelected: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.s) {
                HStack(spacing: Spacing.s) {
                    if let image = article.image,
                       let url = URL(fromString: image) {
                        KFImage(url)
                            .backgroundDecode(true)
                            .resizable()
                            .placeholder {
                                Color.secondaryFill
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        if let source = article.source {
                            Text(source)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        Text(article.title ?? "Untitled Article")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        
                        if let description = article.description {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(2)
                        }
                        
//                        if let publishedAt = article.publishedAt {
//                            Text(publishedAt.timeAgo())
//                                .font(.caption2)
//                                .foregroundStyle(.white.opacity(0.6))
//                        }
                    }
                    
                    Spacer()
                }
                .padding(Padding.m)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(isSelected ? Color.white.opacity(0.3) : Color.clear, lineWidth: 2)
                        )
                )
            }
        }
    }
    
//    @ViewBuilder
//    var commentList: some View {
//        LazyVStack(alignment: .leading, spacing: Spacing.m) {
//            if comments.isEmpty && !isLoadingComments {
//                Text("No comments yet. Be the first to comment!")
//                    .font(.subheadline)
//                    .foregroundStyle(.label3)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.vertical, Padding.vertical)
//            } else {
//                ForEach(Array(comments.enumerated()), id: \.element.id) { index, comment in
//                    ThreadCommentView(comment: comment)
//                        .onAppear {
//                            Task {
//                                guard let threadId = thread.id else { return }
//                                await repository.loadMoreCommentsIfNeeded(for: threadId, currentIndex: index)
//                            }
//                        }
//                }
//                
//                if isLoadingComments {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .label1))
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(Padding.m)
//                }
//            }
//            
//            // footer spacing
//            Color.clear.frame(height: 128)
//        }
//    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        guard let threadId = thread.id else { return }
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    do {
                        try await repository.loadArticles(for: threadId, reset: true)
                    } catch {
                        ContentViewModel.shared.setError(error)
                    }
                }
                
                group.addTask {
                    do {
                        try await repository.loadThreadEntities(for: threadId)
                    } catch {
                        ContentViewModel.shared.setError(error)
                    }
                }
                
                group.addTask {
                    do {
                        try await repository.loadComments(for: threadId, reset: true)
                    } catch {
                        ContentViewModel.shared.setError(error)
                    }
                }
            }
        }
    }
}
