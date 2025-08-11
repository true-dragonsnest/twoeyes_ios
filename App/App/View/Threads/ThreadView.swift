//
//  ThreadView.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI
import Kingfisher

// MARK: - const
extension ThreadView {
    enum Const {
        static let topGradientHeight: CGFloat = 120
        static let bgImageBottomStretch: CGFloat = 120
    }
}

// MARK: - view
struct ThreadView: View {
    let thread: EntityThread
    let detailMode: Bool

    @State var width: CGFloat = 0

    @State var articleCardHeight: CGFloat = 1
    @State var articleScrollPosition = ScrollPosition(id: 0)
    @State var articleScrollOffset: CGFloat = 0
    @State var selectedArticleIndex: Int = 0
    
    @FocusState var focused
    @State var commentSending = false
    
    
    private let repository = ThreadRepository.shared
    
    // TODO: Calculate actual safe area + navigation bar height
    private var topGradientHeight: CGFloat {
        Const.topGradientHeight
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
        articles[safe: selectedArticleIndex]
    }
    
    var body: some View {
        Group {
            if detailMode {
                content
                    .ignoresSafeArea()
                    .navigationTitle("")
                    .toolbarRole(.editor)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbar(.hidden, for: .tabBar)
            } else {
                content
            }
        }
        .readSize {
            width = $0.width
        }
        .onAppear {
            loadInitialData()
        }
        .preferredColorScheme(.dark)
    }
    
    var content: some View {
        ZStack {
            backgroundLayer
            foregroundLayer
        }
        .background(.primaryFill)
    }
    
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
    
// MARK: - background
extension ThreadView {
    var backgroundLayer: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(width: width, height: width)
                .overlay(alignment: .top) {
//                    backgroundImage
//                        .overlay(
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    Color.primaryFill.opacity(0),
//                                    Color.primaryFill.opacity(0.5),
//                                    Color.primaryFill
//                                ]),
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
                }
                .overlay(alignment: .bottom) {
                    threadHeader
                }
            
            Spacer()
        }
        .background(alignment: .top) {
            backgroundImage
                .overlay {
                    VStack(spacing: 0) {
                        LinearGradient(
                            gradient: Gradient(
                                stops: [
                                    .init(color: Color.primaryFill.opacity(0), location: 0.0),
                                    .init(color: Color.primaryFill.opacity(0), location: 0.5),
                                    .init(color: Color.primaryFill.opacity(0.9), location: 1.0)
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: width, height: width + Const.bgImageBottomStretch)
                        Color.primaryFill.opacity(0.9)
                    }
                        
                }
        }
    }
    
    @ViewBuilder
    var backgroundImage: some View {
        let imageHeight = width + Const.bgImageBottomStretch
        VStack(spacing: 0) {
            ForEach(Array(articles.enumerated()), id: \.offset) { index, article in
                Group {
                    if let url = URL(fromString: article.image ?? articles.first?.image) {
                        KFImage(url)
                            .backgroundDecode(true)
                            .resizable()
                            .placeholder {
                                Color.secondaryFill
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: imageHeight)
                            .clipped()
                    } else {
                        Color.secondaryFill
                    }
                }
                .frame(width: width, height: imageHeight)
            }
        }
        .offset(y: -articleScrollOffset * imageHeight / articleCardHeight)
        .overlay(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.primaryFill.opacity(0.8),
                    Color.primaryFill.opacity(0.4),
                    Color.primaryFill.opacity(0)
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
            Text(currentArticle?.mainSubject ?? thread.mainSubject)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.label1)
                .padding(.horizontal, Padding.horizontal)
                .padding(.bottom, Padding.l)
        }
    }
}

// MARK: - foreground
extension ThreadView {
    var foregroundLayer: some View {
        VStack {
            Color.clear
                .frame(width: width, height: width)
            
            articleListView
            
            Color.yellow.frame(height: 100)
                .overlay {
                    Text("Comment area")
                }
        }
        .mask(alignment: .top) {
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: Color.white.opacity(0), location: 0.0),
                            .init(color: Color.white.opacity(0), location: 0.95),
                            .init(color: Color.white, location: 1.0)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: width, height: width + Padding.l)
                
                Color.white
            }
        }
    }
    
    var articleListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                    ArticleCard(article: article, selected: index == selectedArticleIndex)
                        .id(index)
                        .padding(.vertical, Padding.vertical)
                        .frame(height: articleCardHeight)
                        .padding(.horizontal, Padding.horizontal)
                }
            }
            .padding(.vertical, Padding.m)
            .scrollTargetLayout()
        }
        .scrollClipDisabled()
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .readSize {
            articleCardHeight = max(1, $0.height - Spacing.m - 30)
        }
        .scrollPosition($articleScrollPosition)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { oldValue, newValue in
            articleScrollOffset = newValue
        }
        .onChange(of: articleScrollPosition) { _, newValue in
            if let index = newValue.viewID(type: Int.self) {
                selectedArticleIndex = index
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
    
    // MARK: - comment input
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
}
