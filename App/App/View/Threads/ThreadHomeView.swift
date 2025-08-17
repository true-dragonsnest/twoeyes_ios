//
//  ThreadHomeView.swift
//  App
//
//  Created by Yongsik Kim on 5/6/25.
//

import SwiftUI

struct ThreadHomeView: View {
    enum Const {
        static let headerHeight: CGFloat = 100
    }
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
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
        .preferredColorScheme(.dark)
    }
    
    var content: some View {
        threadListView
            .overlay(alignment: .top) {
                if viewModel.categories.count > 1 {
                    categoryFilterView
                }
            }
    }
}

// MARK: - category filters
private extension ThreadHomeView {
    var categoryFilterView: some View {
        ZStack(alignment: .top) {
            Color.black
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.5),
                            .init(color: .black.opacity(0), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.categories, id: \.id) { category in
                        CategoryChip(
                            category: category,
                            isSelected: viewModel.selectedCategory.id == category.id,
                            onTap: {
                                if viewModel.selectedCategory.id != category.id {
                                    viewModel.selectCategory(category)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, Padding.horizontal)
                .padding(.vertical, Padding.vertical)
                .padding(.top, safeAreaInsets.top)
            }
            .scrollClipDisabled()
        }
        .frame(height: Const.headerHeight + safeAreaInsets.top)
        .offset(y: -safeAreaInsets.top)
    }
    
    struct CategoryChip: View {
        let category: EntityCategory
        let isSelected: Bool
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                Text(category.translated ?? category.original)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .label1)
                    .padding(.horizontal, Padding.m)
                    .padding(.vertical, Padding.s)
                    .background(isSelected ? Color.appPrimary : Color.clear)
                    .borderedCapsule(cornerRadius: 24, strokeColor: isSelected ? .clear : .label1, strokeWidth: 1)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - thread list
private extension ThreadHomeView {
    @ViewBuilder
    var threadListView: some View {
        if repository.threads.isEmpty && repository.isLoadingThreads {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .label3))
        } else if repository.threads.isEmpty {
            Text("No threads available")
                .foregroundStyle(.label3)
                .font(.subheadline)
                .fontWeight(.medium)
        } else {
            List {
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
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                if repository.isLoadingThreads && !repository.threads.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .label3))
                        .padding()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 60)
            .refreshable {
                await repository.refresh()
            }
        }
    }
}
