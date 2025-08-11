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
        
        var body: some View {
            content
                .padding(Padding.xl)
                .background(
                    Color.appPrimary.opacity(0.1)
                        .visualEffect({ content, proxy in
                            content
                                .hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 10))
                        })
                )
                .background(.regularMaterial)
                .borderedCapsule(cornerRadius: 24, strokeColor: selected ? Color.red : Color.label3)
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
                }
        }
        
        var content: some View {
            VStack(spacing: Spacing.l) {
                HStack {
                    if let favicon {
                        Image(uiImage: favicon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                    
                    if let title = article.title {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
            .overlay {
                keypointView
            }
        }
        
        @ViewBuilder
        var keypointView: some View {
            if let keyPoints = article.keyPoints {
                VStack(spacing: Spacing.s) {
                    ForEach(0..<keyPoints.count, id: \.self) { index in
                    //ForEach(0..<1) { index in
                        if let text = keyPoints[safe: index] {
                            if showSummary >= index, let text = keyPoints[safe: index] {
                                Text(text)
                                    .customAttribute(EmphasisAttribute())
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(AppearanceTextTransition() {
                                        withAnimation(.smooth(duration: 0.5)) {
                                            showSummary += 1
                                        }
                                    })
                            }
                        }
                    }
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
