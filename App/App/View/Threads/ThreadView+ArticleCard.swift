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
        
        @State var showSummary = -1
        @State var favicon: UIImage?
        @State var keypointScrollPos = ScrollPosition(id: 0)
        @State var keypointScrollViewHeight: CGFloat = 0
        
        var body: some View {
            content
                .padding(Padding.xl)
//                .background(
//                    Color.appPrimary.opacity(0.1)
//                        .visualEffect({ content, proxy in
//                            content
//                                .hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 10))
//                        })
//                )
                .background(.regularMaterial)
                .borderedCapsule(cornerRadius: 24, strokeColor: .label3)
                .onChange(of: selected) { _, val in
                    if val {
                        withAnimation(.smooth(duration: 0.5)) {
                            showSummary += 1
                        }
                    } else {
                        withAnimation(.smooth(duration: 0.5)) {
                            showSummary = -1
                        }
                    }
                }
                .onAppear {
                    showSummary = selected ? 0 : -1
                    loadFavicon()
                    scrollTo(0)
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
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                keypointView
                    .readSize { keypointScrollViewHeight = $0.height }
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    Spacer()
                    
                    if let date = article.createdAt {
                        Text(Date.now, format: .reference(to: date))
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        
        @ViewBuilder
        var keypointView: some View {
            let cellHeight = keypointScrollViewHeight
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    ForEach(0..<(article.keyPoints?.count ?? 0), id: \.self) { index in
                        if showSummary >= index,
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
                                        showSummary += 1
                                    }
                                    scrollTo(index + 1)
                                })
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(1 - abs(phase.value * 0.2))
                                        .opacity(1 - abs(phase.value))
//                                        .blur(radius: phase.isIdentity ? 0 : abs(phase.value) * 2)
//                                        .offset(y: -phase.value * cellHeight / 2)
                                }
                        }
                    }
                }
            }
            .scrollPosition($keypointScrollPos)
            .scrollDisabled(true)
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
