//
//  ThreadCardView.swift
//  App
//
//  Created by Yongsik Kim on 5/4/25.
//

import SwiftUI
import Kingfisher

struct ThreadCardView: View {
    enum Const {
        static let articleListHeight: CGFloat = 300
    }
    
    let thread: EntityThread
    
    var body: some View {
        content
            .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    var content: some View {
        if thread.articleSnapshots?.count ?? 0 > 1 {
            VStack(spacing: Spacing.m) {
                subjectHeader
                articleList
            }
        } else {
            VStack(spacing: Spacing.m) {
                if let article = thread.articleSnapshots?.first {
                    ArticleCard(article: article, fitWidth: true, height: 0)
                }
                subjectHeader
            }
        }
    }
    
    var subjectHeader: some View {
        Text(thread.mainSubject)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.label1)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Padding.horizontal)
    }
    
    @ViewBuilder
    var articleList: some View {
        if let articles = thread.articleSnapshots, !articles.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.xs) {
                    ForEach(articles) { article in
                        ArticleCard(article: article, fitWidth: false, height: Const.articleListHeight)
                    }
                }
                .padding(.horizontal, Padding.horizontal)
            }
            .scrollClipDisabled()
        }
    }
}

// MARK: - article card view
private extension ThreadCardView {
    struct ArticleCard: View {
        @Environment(\.sceneSize) var sceneSize
        
        let article: EntityThread.ArticleSnapshot
        let fitWidth: Bool
        let height: CGFloat
        
        @State var image: UIImage?
        @State var favicon: UIImage?
        
        var body: some View {
            Group {
                if fitWidth {
                    fitImageView
                } else {
                    fixedHeightImageView
                }
            }
            .overlay(alignment: .bottomLeading) {
                overlayView
                    .padding(Padding.m)
            }
            .onAppear {
                loadImage()
                loadFavicon()
            }
        }
        
        @ViewBuilder
        var fitImageView: some View {
            if let image {
                let fitToSquare = image.size.aspectRatio < 1
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(fitToSquare ? 1 : image.size.aspectRatio, contentMode: .fit)
                    .frame(width: sceneSize.width)
            } else {
                Color.background
                    .frame(width: sceneSize.width, height: sceneSize.width)
            }
        }
        
        @ViewBuilder
        var fixedHeightImageView: some View {
            if let url = URL(fromString: article.image) {
                KFImage(url)
                    .backgroundDecode(true)
                    .resizable()
                    .placeholder {
                        Color.background
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        
        var overlayView: some View {
            HStack {
                if let favicon {
                    Image(uiImage: favicon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .borderedCapsule(cornerRadius: 4, strokeColor: .clear)
                }
//
//                                if let title = article.title {
//                                    Text(title.htmlDecoded)
//                                        .font(.headline)
//                                        .fontWeight(.semibold)
//                                        .multilineTextAlignment(.leading)
//                                        .lineLimit(2)
//                                        .foregroundStyle(.label2)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                }
                Spacer()
            }
        }
        
        func loadImage() {
            guard let url = URL(fromString: article.image) else { return }
            
            Task {
                if let image = try? await UseCases.ImageFetch.fetch(from: url) {
                    await MainActor.run {
                        withAnimation {
                            self.image = image
                        }
                    }
                }
            }
        }
        
        func loadFavicon() {
            guard favicon == nil, let url = article.source else { return }
            
            Task {
                if let image = await UseCases.Favicon.loadFavicon(from: url) {
                    await MainActor.run {
                        withAnimation {
                            self.favicon = image
                        }
                    }
                }
            }
        }
    }
}
