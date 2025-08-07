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
            .preferredColorScheme(.dark)
    }
    
    var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: sceneSize.width)
                
                LazyVStack(spacing: Spacing.m) {
                    ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                        ArticleCard(article: article, selected: index == selectedArticleIndex)
                            .id(index)
//                            .scrollTransition(
//                                    axis: .horizontal
//                                ) { content, phase in
//                                    content
//                                        .rotationEffect(.degrees(phase.value * 2.5))
//                                        .offset(y: phase.isIdentity ? 0 : 8)
//                                }
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
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, Padding.horizontal)
                .padding(.bottom, Padding.l)
            
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
        let selected: Bool
        
        @State var showSummary = -1
        
        var body: some View {
            content
                .padding(Padding.xl)
                .background(
                    Color.appPrimary.opacity(0.1)
                        .visualEffect({ content, proxy in
                            content
                                .hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 10))
                        })
                )
                .background(.regularMaterial)
                .borderedCapsule(cornerRadius: 24, strokeColor: .label3)
                .onChange(of: selected) { _, val in
                    if val {
                        withAnimation(.smooth(duration: 0.5)) {
                            showSummary += 1
                        }
                    } else {
                        withAnimation(.smooth(duration: 0.5)) {
                            showSummary = -1
                        }
                    }
                }
        }
        
        var content: some View {
            VStack(spacing: Spacing.l) {
                HStack(alignment: .top) {
                    if let source = article.source {
                        Text(source)
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Text(article.title ?? "")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                }
                    
                if let mainSubject = article.mainSubject {
                    Text(mainSubject)
                        .font(.title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                }
                
                if let keyPoints = article.keyPoints {
                    VStack(spacing: Spacing.s) {
                        ForEach(0..<keyPoints.count) { index in
                            if let text = keyPoints[safe: index] {
                                Text(text)
                                    .font(.title2)
                                    .customAttribute(EmphasisAttribute())
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(AppearanceTextTransition() {
                                        withAnimation(.smooth(duration: 0.5)) {
                                            showSummary += 1
                                        }
                                    })
                            }
                        }
                    }
                }
                
                HStack(alignment: .bottom) {
                    Spacer()
                    
                    if let date = article.createdAt {
                        Text(Date.now, format: .reference(to: date))
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
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
