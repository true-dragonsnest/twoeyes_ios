//
//  ThreadHomeView.swift
//  App
//
//  Created by Yongsik Kim on 5/6/25.
//

import SwiftUI

struct ThreadHomeView: View {
    @State var viewModel = ThreadHomeViewModel()
    
    private let repository = ThreadRepository.shared
    
    var body: some View {
        NavigationStack(path: $viewModel.navPath) {
            content
                .navigationDestination(for: ThreadHomeViewModel.NavPath.self) { navPath in
                    switch navPath {
                    case .thread(let entity):
                        ThreadView(thread: entity, detailMode: true)
                    }
                }
        }
        .onAppear {
            Task {
                do {
                    try await repository.loadThreads(reset: true)
                } catch {
                    ContentViewModel.shared.setError(error)
                }
            }
        }
    }
    
    var content: some View {
        threadListView
    }
    
    @ViewBuilder
    var threadListView: some View {
        if repository.threads.isEmpty && repository.isLoadingThreads {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .label3))
        } else if repository.threads.isEmpty {
            Text("No threads available")
                .foregroundStyle(.label3)
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: Spacing.xxl) {
                    ForEach(repository.threads, id: \.id) { thread in
                        ThreadCardView(thread: thread)
                            .onTapGesture {
                                viewModel.navToThread(thread)
                            }
                            .onAppear {
                                if let index = repository.threads.firstIndex(where: { $0.id == thread.id }) {
                                    Task {
                                        await repository.loadMoreThreadsIfNeeded(currentIndex: index)
                                    }
                                }
                            }
                            .padding(.bottom, Padding.xl)
                    }
                }
                
                if repository.isLoadingThreads && !repository.threads.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .label3))
                        .padding()
                }
            }
            .refreshable {
                await repository.refresh()
            }
        }
    }
}

