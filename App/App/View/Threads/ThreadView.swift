//
//  ThreadView.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI
import Kingfisher

struct ThreadView: View {
    @ObservedObject var viewModel: ThreadViewModel
    
    var body: some View {
        content
            .navigationTitle(viewModel.thread.title ?? "Thread")
            .toolbarRole(.editor)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                commentInput
                    .padding()
            }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                imageCarousel
                    .padding(.horizontal, 16)
                
                commentList
                    .padding(.horizontal, 16)
            }
        }
    }
    
    @ViewBuilder
    var imageCarousel: some View {
        let height: CGFloat = 300
        
        if let images = viewModel.thread.images {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
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
    var commentList: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            if viewModel.comments.isEmpty && !viewModel.isLoadingComments {
                Text("No comments yet. Be the first to comment!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                ForEach(Array(viewModel.comments.enumerated()), id: \.element.id) { index, comment in
                    commentRow(comment: comment)
                        .onAppear {
                            Task {
                                await viewModel.loadMoreCommentsIfNeeded(currentIndex: index)
                            }
                        }
                    
                    if index < viewModel.comments.count - 1 {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
                
                if viewModel.isLoadingComments {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
    }
    
    @ViewBuilder
    func commentRow(comment: EntityComment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(.secondary)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.userId)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(comment.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                if comment.isAiGenerated {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("AI Generated")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: comment input
    @FocusState var focused
    var commentInput: some View {
        InputBar(text: "Drop a comment",
                 focused: $focused,
                 sendEnabled: true)
        { comment, commentAttachments in
            Task {
                do {
                    try await viewModel.postComment(content: comment)
                } catch {
                    ContentViewModel.shared.setError(error)
                }
            }
        }
    }
}
