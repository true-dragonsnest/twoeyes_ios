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
        
        @State var selectedEntityReasoning: String? = nil
        
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
                            nerSentimentCapsule(for: entitySentiment)
                        }
                    }
                }
                .scrollClipDisabled()
            }
        }
        
        @ViewBuilder
        func nerSentimentCapsule(for entitySentiment: EntityArticle.EntitySentiment) -> some View {
            let absValue: CGFloat = CGFloat(abs(entitySentiment.sentiment))
            let intensity: CGFloat = min(absValue, 1.0)
            let threshold: Float = 0.5
            
            HStack(spacing: 6) {
                Text(entitySentiment.entity)
                    .font(.subheadline)
                    .fontWeight(absValue > 0.6 ? .bold : .medium)
                    .foregroundStyle(.white)
                
                if entitySentiment.sentiment > threshold {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .scaleEffect(1 + intensity * 0.3)
                        .shadow(color: .white.opacity(0.5), radius: intensity * 3)
                } else if entitySentiment.sentiment < -threshold {
                    Image(systemName: "hand.thumbsdown.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .scaleEffect(1 + intensity * 0.3)
                        .shadow(color: .white.opacity(0.5), radius: intensity * 3)
                }
            }
            .padding(.horizontal, Padding.s * (1 + intensity * 0.3))
            .padding(.vertical, Padding.s)
            .background(.thinMaterial)
            .background((entitySentiment.sentiment > 0 ? Color.blue : Color.red).opacity(intensity))
            .borderedCapsule(cornerRadius: 24,
                             strokeColor: entitySentiment.sentiment > 0 ? Color.blue : Color.red,
                             strokeWidth: 1 + intensity)
            .onTapGesture {
                if let reasoning = entitySentiment.reasoning, !reasoning.isEmpty {
                    selectedEntityReasoning = reasoning
                }
            }
            .popover(
                isPresented: Binding(
                    get: { selectedEntityReasoning == entitySentiment.reasoning && selectedEntityReasoning != nil },
                    set: { newValue in
                        if !newValue {
                            selectedEntityReasoning = nil
                        }
                    }
                )
            ) {
                Text(entitySentiment.reasoning ?? "")
                    .font(.caption)
                    .foregroundStyle(.label1)
                    .padding(.horizontal, Padding.m)
                    .padding(.vertical, Padding.s)
                    .frame(maxWidth: 200)
                    .presentationCompactAdaptation(.popover)
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
                        self.favicon = image
                    }
                }
            }
        }
    }
}
