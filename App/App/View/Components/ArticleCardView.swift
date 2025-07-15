//
//  ArticleCardView.swift
//  App
//
//  Created by Yongsik Kim on 3/9/25.
//

import SwiftUI
import Kingfisher

struct ArticleCardView: View {
    let article: EntityArticle
    let selected: Bool
    
    @State var width: CGFloat = 0
    @State var bgColor: Color = .clear
    
    @State var showSummary = -1
    
    var body: some View {
        cardView
    }
    
    var cardView: some View {
        contentView
            .background(
                LinearGradient(
                    gradient: .init(colors: [
                        bgColor.opacity(0.5),
                        bgColor.opacity(0.4),
                        bgColor.opacity(0.3),
                        bgColor.opacity(0.1),
                        bgColor.opacity(0.3),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .animation(.smooth, value: bgColor)
            .background(article.image != nil ? AnyShapeStyle(.regularMaterial) : Color.clear.any)
            .borderedCapsule(cornerRadius: 24, strokeColor: .label3)
            .readSize {
                width = $0.width
            }
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
                //getImageColorIfNeeded()
                bgColor = (article.sentimentEnum?.color ?? .clear).opacity(0.5)
                showSummary = selected ? 0 : -1
            }
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            imageView
                .overlay(alignment: .bottom) {
                    subjectView
                        .padding()
                }
            
            sourceView
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            summaryView
                .padding(.horizontal)
            
            Spacer()
            
            dateView
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
        .aspectRatio(9 / 16, contentMode: .fit)
    }
    
    @ViewBuilder
    var imageView: some View {
        if let imageUrl = URL(fromString: article.image) {
            let width = max(0, self.width - 4 * 2)
            KFImage(imageUrl)
                .backgroundDecode(true)
                .resizable()
                .placeholder {
                    Color.secondaryFill
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: width)
                .clipShape(.rect(cornerRadius: 20))
                .padding(4)
        }
    }
    
    @ViewBuilder
    var subjectView: some View {
        if let subject = article.mainSubject {
            HStack {
//                if let sentimentIcon = article.sentiment?.icon {
//                    sentimentIcon.iconButton(font: .headline, monochrome: article.sentiment?.color ?? .clear)
//                }
                if let sentimentIcon = article.sentimentEnum?.icon {
                    Text(sentimentIcon)
                        .font(.title)
                }
                Text(subject)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background((article.sentimentEnum?.color ?? .clear).opacity(0.1))
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    var summaryView: some View {
        if let keyPoints = article.keyPoints {
            VStack(spacing: 8) {
                ForEach(0..<keyPoints.count) { index in
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
//        if let summary = article.summary, showSummary {
//            Text(summary)
//                .customAttribute(EmphasisAttribute())
//                .font(.title2)
//                .multilineTextAlignment(.leading)
//                .lineSpacing(8)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .transition(AppearanceTextTransition())
//        }
    }
    
    var sourceView: some View {
        HStack(alignment: .top) {
            if let source = article.source {
                Text(source)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.label2)
            }
            
            Text(article.title ?? "")
                .font(.caption)
                .foregroundStyle(.label2)
                //.lineLimit(1)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var dateView: some View {
        if let date = article.createdAt {
            Text(Date.now, format: .reference(to: date))
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.label2)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - bg color from image dominant color
extension ArticleCardView {
    func getImageColorIfNeeded() {
        guard bgColor == .clear, let imageUrl = article.image else { return }
        Task {
            guard let image = try? await UseCases.Download.image(from: imageUrl),
                  let color = image.dominantColor else { return }
            bgColor = Color(uiColor: color)
        }
    }
}

