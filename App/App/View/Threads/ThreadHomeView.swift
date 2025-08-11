//
//  ThreadHomeView.swift
//  App
//
//  Created by Yongsik Kim on 5/6/25.
//

import SwiftUI

struct ThreadHomeView: View {
    @Environment(\.sceneSize) var sceneSize
    
    @State var viewModel = ThreadHomeViewModel()
    
    private let repository = ThreadRepository.shared
    
    var cellWidth: CGFloat {
        max(1, (sceneSize.width - Spacing.m * 3) / 2)
    }
    
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
                HStack(alignment: .top, spacing: Spacing.m) {
                    LazyVStack(spacing: Spacing.m) {
                        ForEach(0..<repository.threads.count, id: \.self) { index in
                            if index % 2 == 0 {
                                let thread = repository.threads[index]
                                ThreadCardView(thread: thread)
                                    .onTapGesture {
                                        viewModel.navToThread(thread)
                                    }
                                    .onAppear {
                                        Task {
                                            await repository.loadMoreThreadsIfNeeded(currentIndex: index)
                                        }
                                    }
                            }
                        }
                    }
                    .frame(width: cellWidth)
                    
                    LazyVStack(spacing: Spacing.m) {
                        ForEach(0..<repository.threads.count, id: \.self) { index in
                            if index % 2 == 1 {
                                let thread = repository.threads[index]
                                ThreadCardView(thread: thread)
                                    .onTapGesture {
                                        viewModel.navToThread(thread)
                                    }
                                    .onAppear {
                                        Task {
                                            await repository.loadMoreThreadsIfNeeded(currentIndex: index)
                                        }
                                    }
                            }
                        }
                    }
                    .frame(width: cellWidth)
                }
                .padding(.horizontal, Padding.m)
                
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

