//
//  ThreadView.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI
import Kingfisher

struct ThreadView: View {
    let thread: EntityThread
    
    @State var commentSending = false
    
    private let repository = ThreadRepository.shared
    
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
    
    var body: some View {
        content
            .navigationTitle(thread.title ?? "Thread")
            .toolbarRole(.editor)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                commentInput
                    .padding(Padding.m)
            }
            .onAppear {
                loadInitialData()
            }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                imageCarousel
                    .padding(.horizontal, Padding.horizontal)
                
                articlesSection
                    .padding(.horizontal, Padding.horizontal)
                
                threadEntitiesSection
                    .padding(.horizontal, Padding.horizontal)
                
                commentList
                    .padding(.horizontal, Padding.horizontal)
            }
        }
    }
    
    @ViewBuilder
    var imageCarousel: some View {
        let height: CGFloat = 300
        
        if let images = thread.images, !images.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(Array(images.enumerated()), id: \.0) { index, image in
                        if let url = URL(fromString: image) {
                            KFImage(url)
                                .backgroundDecode(true)
                                .resizable()
                                .placeholder {
                                    Color.secondaryFill
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(height: height)
                        }
                    }
                }
            }
            .background(.clear)
            .frame(height: height)
            .borderedCapsule(cornerRadius: 12, strokeColor: .label3)
        }
    }
    
    @ViewBuilder
    var articlesSection: some View {
        if !articles.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Articles")
                    .font(.headline)
                    .foregroundStyle(.label1)
                
                ForEach(articles) { article in
                    // Article view implementation
                    Text(article.title ?? "Untitled Article")
                        .font(.subheadline)
                        .foregroundStyle(.label2)
                }
            }
        }
    }
    
    @ViewBuilder
    var threadEntitiesSection: some View {
        if !threadEntities.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Key Entities")
                    .font(.headline)
                    .foregroundStyle(.label1)
                
                LazyVStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(threadEntities) { entity in
                        HStack {
                            Text(entity.entityName)
                                .font(.subheadline)
                                .foregroundStyle(.label2)
                            
                            Spacer()
                            
                            if let sentiment = entity.averageSentiment {
                                Text(String(format: "%.2f", sentiment))
                                    .font(.caption)
                                    .foregroundStyle(sentiment > 0 ? .green : sentiment < 0 ? .red : .label3)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var commentList: some View {
        LazyVStack(alignment: .leading, spacing: Spacing.m) {
            if comments.isEmpty && !isLoadingComments {
                Text("No comments yet. Be the first to comment!")
                    .font(.subheadline)
                    .foregroundStyle(.label3)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Padding.vertical)
            } else {
                ForEach(Array(comments.enumerated()), id: \.element.id) { index, comment in
                    ThreadCommentView(comment: comment)
                        .onAppear {
                            Task {
                                guard let threadId = thread.id else { return }
                                await repository.loadMoreCommentsIfNeeded(for: threadId, currentIndex: index)
                            }
                        }
                }
                
                if isLoadingComments {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .label1))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(Padding.m)
                }
            }
            
            // footer spacing
            Color.clear.frame(height: 128)
        }
    }
    
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
}
