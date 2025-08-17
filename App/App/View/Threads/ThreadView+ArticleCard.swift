//
//  ThreadView+ArticleCard.swift
//  App
//
//  Created by Assistant on 1/11/25.
//

import SwiftUI
import Kingfisher

extension ThreadView {
    struct ArticleCard: View {
        let article: EntityArticle
        let selected: Bool
        
        @State var keypointProgress = -1
        @State var favicon: UIImage?
        @State var keypointScrollPos = ScrollPosition(id: 0)
        @State var keypointScrollViewHeight: CGFloat = 0
        
        var body: some View {
            content
                .padding(Padding.xl)
                .background(.regularMaterial)
                .borderedCapsule(cornerRadius: 24, strokeColor: .label3)
                .onChange(of: selected) { _, val in
                    if val {
                        withAnimation(.smooth(duration: 0.5)) {
                            keypointProgress = 0
                        }
                    } else {
                        withAnimation(.smooth(duration: 0.2)) {
                            keypointProgress = -1
                        }
                    }
                }
                .onAppear {
                    keypointProgress = selected ? 0 : -1
                    loadFavicon()
                }
        }
        
        var content: some View {
            VStack(spacing: Spacing.l) {
                HStack {
                    if let favicon {
                        Image(uiImage: favicon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .borderedCapsule(cornerRadius: 4, strokeColor: .clear)
                    } else {
                        Circle().fill(.regularMaterial)
                            .frame(width: 36, height: 36)
                    }
                    
                    if let title = article.title {
                        Text(title.htmlDecoded)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .foregroundStyle(.label2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                keypointView
                    .readSize { keypointScrollViewHeight = $0.height }
                
                Spacer()
                
                entityListView
            }
        }
        
        @ViewBuilder
        var keypointView: some View {
            let cellHeight = keypointScrollViewHeight
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    Color.clear.frame(height: cellHeight)
                        .id(-999)
                    ForEach(0..<(article.keyPoints?.count ?? 0), id: \.self) { index in
                        if keypointProgress >= index,
                           let text = article.keyPoints?[safe: index] {
                            Text(text)
                                .customAttribute(EmphasisAttribute())
                                .font(.title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: cellHeight)
                                .id(index)
                                .transition(AppearanceTextTransition() {
                                    withAnimation(.smooth(duration: 0.5)) {
                                        keypointProgress += 1
                                    }
                                })
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(1 - abs(phase.value * 0.2))
                                        .opacity(1 - abs(phase.value))
                                        .blur(radius: phase.isIdentity ? 0 : abs(phase.value) * 2)
                                }
                                .onAppear {
                                    scrollTo(index)
                                }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .scrollPosition($keypointScrollPos)
            .scrollDisabled(true)
        }
        
        @ViewBuilder
        var entityListView: some View {
            if let entities = article.sentimentEntitySpecific, !entities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.s) {
                        ForEach(entities, id: \.entity) { entitySentiment in
                            NERSentimentBadge(
                                entity: entitySentiment.entity,
                                sentiment: entitySentiment.sentiment,
                                reasoning: entitySentiment.reasoning
                            )
                        }
                    }
                }
                .scrollClipDisabled()
            }
        }
        
        func scrollTo(_ index: Int) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    keypointScrollPos.scrollTo(id: index, anchor: .center)
                }
            }
        }
        
        private func loadFavicon() {
            guard favicon == nil else { return }
            
            Task {
                if let image = await UseCases.Favicon.loadFavicon(from: article.url) {
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
