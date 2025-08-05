//
//  ThreadViewModel.swift
//  App
//
//  Created by Yongsik Kim on 8/5/25.
//

import SwiftUI
import Combine

class ThreadViewModel: ObservableObject {
    let thread: EntityThread
    
    @Published var articles: [EntityArticle] = []
    @Published var comments: [EntityComment] = []
    @Published var isLoadingArticles = false
    @Published var isLoadingComments = false
    @Published var hasMoreComments = true
    @Published var error: Error?
    
    private var currentOffset = 0
    private let pageSize = 20
    private var cancellables = Set<AnyCancellable>()
    
    init(thread: EntityThread) {
        self.thread = thread
        Task {
            await fetchInitialData()
        }
    }
    
    @MainActor
    func fetchInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchArticles() }
            group.addTask { await self.fetchComments(reset: true) }
        }
    }
    
    @MainActor
    func fetchArticles() async {
        guard let threadId = thread.id else { return }
        
        isLoadingArticles = true
        defer { isLoadingArticles = false }
        
        do {
            articles = try await UseCases.Articles.fetchForThread(threadId: threadId)
        } catch {
            self.error = error
            print("Failed to fetch articles: \(error)")
        }
    }
    
    @MainActor
    func fetchComments(reset: Bool = false) async {
        guard let threadId = thread.id else { return }
        guard !isLoadingComments || reset else { return }
        
        if reset {
            currentOffset = 0
            comments = []
            hasMoreComments = true
        }
        
        guard hasMoreComments else { return }
        
        isLoadingComments = true
        defer { isLoadingComments = false }
        
        do {
            let response = try await UseCases.Comment.getThreadComments(
                threadId: threadId,
                limit: pageSize,
                offset: currentOffset,
                sortBy: "created_at",
                sortOrder: "desc"
            )
            
            if reset {
                comments = response.comments
            } else {
                comments.append(contentsOf: response.comments)
            }
            
            currentOffset = response.nextOffset ?? (currentOffset + response.comments.count)
            hasMoreComments = response.nextOffset != nil
        } catch {
            self.error = error
            print("Failed to fetch comments: \(error)")
        }
    }
    
    @MainActor
    func loadMoreCommentsIfNeeded(currentIndex: Int) async {
        guard currentIndex >= comments.count - 3,
              hasMoreComments,
              !isLoadingComments else { return }
        
        await fetchComments()
    }
    
    @MainActor
    func postComment(content: String, userSentiment: Double? = nil) async throws {
        guard let threadId = thread.id else { return }
        
        let response = try await UseCases.Comment.addComment(
            threadId: threadId,
            content: content,
            userSentiment: userSentiment
        )
        
        comments.insert(response.comment, at: 0)
    }
    
    @MainActor
    func deleteComment(commentId: String) async throws {
        _ = try await UseCases.Comment.deleteComment(commentId: commentId)
        comments.removeAll { $0.id == commentId }
    }
    
    @MainActor
    func updateComment(commentId: String, content: String, userSentiment: Double? = nil) async throws {
        let response = try await UseCases.Comment.updateComment(
            commentId: commentId,
            content: content,
            userSentiment: userSentiment
        )
        
        if let index = comments.firstIndex(where: { $0.id == commentId }) {
            comments[index] = response.comment
        }
    }
}