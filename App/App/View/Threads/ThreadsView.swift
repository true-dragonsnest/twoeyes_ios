//
//  ThreadsView.swift
//  App
//
//  Created by Yongsik Kim on 5/6/25.
//

import SwiftUI

struct ThreadsView: View {
    @Environment(\.sceneSize) var sceneSize
    
    @State var list = PaginatedList<EntityThread, Int>(pageSize: 10, triggerOffset: 5) { nextToken, pageSize in
        let articles = try await UseCases.Threads.fetchList(from: nextToken, limit: pageSize)
        return (articles, articles.last?.id)
    }
    
    var cellWidth: CGFloat {
        max(1, (sceneSize.width - Const.hPadding * 3) / 2)
    }
    
    var body: some View {
        if list.items.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .label3))
                .onAppear {
                    list.prefetchIfNeeded(at: 0)
                }
        } else {
            content
        }
    }
    
    var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack(alignment: .top, spacing: Const.hPadding) {
                LazyVStack(spacing: Const.hPadding) {
                    ForEach(0..<list.items.count, id: \.self) { index in
                        if index % 2 == 0, let thread = list.items[safe: index] {
                            ThreadCardView(thread: thread)
                        }
                    }
                }
                .frame(width: cellWidth)
                
                LazyVStack(spacing: Const.hPadding) {
                    ForEach(0..<list.items.count, id: \.self) { index in
                        if index % 2 == 1, let thread = list.items[safe: index] {
                            ThreadCardView(thread: thread)
                        }
                    }
                }
                .frame(width: cellWidth)
            }
            .padding(.horizontal, Const.hPadding)
        }
    }
}

extension ThreadsView {
    enum Const {
        static let hPadding: CGFloat = 12
    }
}
