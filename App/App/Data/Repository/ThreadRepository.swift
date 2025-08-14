//
//  ThreadRepository.swift
//  App
//
//  Created by Yongsik Kim on 8/7/25.
//

import SwiftUI

private let T = #fileID

@Observable
class ThreadRepository {
    private enum Const {
        static let threadsPageSize = 20
        static let articlesPageSize = 20
        static let commentsPageSize = 20
        static let loadMoreThreshold = 3
    }
    
    var threads: [EntityThread] = []
    var threadArticles: [Int: [EntityArticle]] = [:]
    var threadEntities: [Int: [EntityThreadEntity]] = [:]
    var threadComments: [Int: [EntityComment]] = [:]
    
    var isLoadingThreads = false
    var isLoadingArticles: [Int: Bool] = [:]
    var isLoadingEntities: [Int: Bool] = [:]
    var isLoadingComments: [Int: Bool] = [:]
    
    var hasMoreThreads = true
    var hasMoreArticles: [Int: Bool] = [:]
    var hasMoreComments: [Int: Bool] = [:]
    
    private var articlesOffset: [Int: Int] = [:]
    private var commentsOffset: [Int: Int] = [:]
    
    static let shared = ThreadRepository()
    
    private init() {}
    
    // MARK: - Thread Management
    @MainActor
    func loadThreads(reset: Bool = false) async throws {
        guard !isLoadingThreads || reset else { return }
        
        if reset {
            threads = []
            hasMoreThreads = true
        }
        
        guard hasMoreThreads else { return }
        
        isLoadingThreads = true
        defer { isLoadingThreads = false }
        
        let startUpdatedAt = reset ? nil : threads.last?.updatedAt
        
        do {
            let newThreads = try await UseCases.Threads.fetchList(from: startUpdatedAt, limit: Const.threadsPageSize)
            
            if reset {
                threads = newThreads
            } else {
                threads.append(contentsOf: newThreads)
            }
            
            hasMoreThreads = newThreads.count == Const.threadsPageSize
            
            // Load thread entities for each thread in parallel
            await withTaskGroup(of: Void.self) { group in
                for thread in newThreads {
                    guard let threadId = thread.id else { continue }
                    group.addTask {
                        do {
                            try await self.loadThreadEntities(for: threadId)
                        } catch {
                            "Failed to load thread entities for thread \(threadId): \(error)".le(T)
                        }
                    }
                }
            }
            
        } catch {
            "Failed to load threads: \(error)".le(T)
            throw error
        }
    }
    
    @MainActor
    func loadMoreThreadsIfNeeded(currentIndex: Int) async {
        guard currentIndex >= threads.count - Const.loadMoreThreshold,
              hasMoreThreads,
              !isLoadingThreads else { return }
        
        do {
            try await loadThreads()
        } catch {
            "Failed to load more threads: \(error)".le(T)
            ContentViewModel.shared.setError(error)
        }
    }
    
    func getThread(by id: Int) -> EntityThread? {
        return threads.first { $0.id == id }
    }
    
    @MainActor
    func updateThread(_ updatedThread: EntityThread) {
        if let index = threads.firstIndex(where: { $0.id == updatedThread.id }) {
            threads[index] = updatedThread
        }
    }
    
    // MARK: - Article Management
    
    @MainActor
    func loadArticles(for threadId: Int, reset: Bool = false) async throws {
        guard !(isLoadingArticles[threadId] ?? false) || reset else { return }
        
        if reset {
            threadArticles[threadId] = []
            articlesOffset[threadId] = 0
            hasMoreArticles[threadId] = true
        }
        
        guard hasMoreArticles[threadId] ?? true else { return }
        
        isLoadingArticles[threadId] = true
        defer { isLoadingArticles[threadId] = false }
        
        do {
            let articles = try await UseCases.Articles.fetchForThread(threadId: threadId)
            
            if reset {
                threadArticles[threadId] = articles
            } else {
                var existingArticles = threadArticles[threadId] ?? []
                existingArticles.append(contentsOf: articles)
                threadArticles[threadId] = existingArticles
            }
            
            hasMoreArticles[threadId] = articles.count == Const.articlesPageSize
            
            // Prefetch favicons for all articles
            prefetchFavicons(for: articles)
            
        } catch {
            "Failed to load articles for thread \(threadId): \(error)".le(T)
            throw error
        }
    }
    
    @MainActor
    func loadMoreArticlesIfNeeded(for threadId: Int, currentIndex: Int) async {
        let articles = threadArticles[threadId] ?? []
        guard currentIndex >= articles.count - Const.loadMoreThreshold,
              hasMoreArticles[threadId] ?? true,
              !(isLoadingArticles[threadId] ?? false) else { return }
        
        do {
            try await loadArticles(for: threadId)
        } catch {
            "Failed to load more articles for thread \(threadId): \(error)".le(T)
            ContentViewModel.shared.setError(error)
        }
    }
    
    // MARK: - Thread Entities Management
    
    @MainActor
    func loadThreadEntities(for threadId: Int) async throws {
        guard !(isLoadingEntities[threadId] ?? false) else { return }
        
        isLoadingEntities[threadId] = true
        defer { isLoadingEntities[threadId] = false }
        
        do {
            let entities = try await UseCases.Threads.fetchThreadEntities(threadId: threadId)
            threadEntities[threadId] = entities
        } catch {
            "Failed to load thread entities for thread \(threadId): \(error)".le(T)
            throw error
        }
    }
    
    // MARK: - Comments Management
    
    @MainActor
    func loadComments(for threadId: Int, reset: Bool = false) async throws {
        guard !(isLoadingComments[threadId] ?? false) || reset else { return }
        
        if reset {
            threadComments[threadId] = []
            commentsOffset[threadId] = 0
            hasMoreComments[threadId] = true
        }
        
        guard hasMoreComments[threadId] ?? true else { return }
        
        isLoadingComments[threadId] = true
        defer { isLoadingComments[threadId] = false }
        
        let currentOffset = commentsOffset[threadId] ?? 0
        
        do {
            let response = try await UseCases.Comment.getThreadComments(
                threadId: threadId,
                limit: Const.commentsPageSize,
                offset: currentOffset,
                sortBy: "created_at",
                sortOrder: "desc"
            )
            
            if reset {
                threadComments[threadId] = response.comments
            } else {
                var existingComments = threadComments[threadId] ?? []
                existingComments.append(contentsOf: response.comments)
                threadComments[threadId] = existingComments
            }
            
            commentsOffset[threadId] = response.nextOffset ?? (currentOffset + response.comments.count)
            hasMoreComments[threadId] = response.nextOffset != nil
            
        } catch {
            "Failed to load comments for thread \(threadId): \(error)".le(T)
            throw error
        }
    }
    
    @MainActor
    func loadMoreCommentsIfNeeded(for threadId: Int, currentIndex: Int) async {
        let comments = threadComments[threadId] ?? []
        guard currentIndex >= comments.count - Const.loadMoreThreshold,
              hasMoreComments[threadId] ?? true,
              !(isLoadingComments[threadId] ?? false) else { return }
        
        do {
            try await loadComments(for: threadId)
        } catch {
            "Failed to load more comments for thread \(threadId): \(error)".le(T)
            ContentViewModel.shared.setError(error)
        }
    }
    
    @MainActor
    func addComment(to threadId: Int, content: String, userSentiment: Double? = nil) async throws {
        do {
            let response = try await UseCases.Comment.addComment(
                threadId: threadId,
                content: content,
                userSentiment: userSentiment
            )
            
            var existingComments = threadComments[threadId] ?? []
            existingComments.insert(response.comment, at: 0)
            threadComments[threadId] = existingComments
        } catch {
            "Failed to add comment to thread \(threadId): \(error)".le(T)
            throw error
        }
    }
    
    @MainActor
    func updateComment(commentId: String, content: String, userSentiment: Double? = nil) async throws {
        do {
            let response = try await UseCases.Comment.updateComment(
                commentId: commentId,
                content: content,
                userSentiment: userSentiment
            )
            
            for (threadId, comments) in threadComments {
                if let index = comments.firstIndex(where: { $0.id == commentId }) {
                    var updatedComments = comments
                    updatedComments[index] = response.comment
                    threadComments[threadId] = updatedComments
                    break
                }
            }
        } catch {
            "Failed to update comment \(commentId): \(error)".le(T)
            throw error
        }
    }
    
    @MainActor
    func deleteComment(commentId: String) async throws {
        do {
            _ = try await UseCases.Comment.deleteComment(commentId: commentId)
            
            for (threadId, comments) in threadComments {
                let updatedComments = comments.filter { $0.id != commentId }
                if updatedComments.count != comments.count {
                    threadComments[threadId] = updatedComments
                    break
                }
            }
        } catch {
            "Failed to delete comment \(commentId): \(error)".le(T)
            throw error
        }
    }
    
    // MARK: - Refresh
    @MainActor
    func refresh() async {
        do {
            try await loadThreads(reset: true)
        } catch {
            "Failed to refresh threads: \(error)".le(T)
            ContentViewModel.shared.setError(error)
        }
    }
    
    // MARK: - Favicon Prefetch
    private func prefetchFavicons(for articles: [EntityArticle]) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for article in articles {
                    group.addTask {
                        _ = await UseCases.Favicon.loadFavicon(from: article.url)
                    }
                }
            }
        }
    }
}
