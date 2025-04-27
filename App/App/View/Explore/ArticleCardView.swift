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
    
    @State var showSummary = false
    
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
            .clipShape(.rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.label3, lineWidth: 1)
            }
            .readSize {
                width = $0.width
            }
            .onChange(of: selected) { _, val in
                if val {
                    withAnimation(.smooth(duration: 0.5)) {
                        showSummary = true
                    }
                } else {
                    withAnimation(.smooth(duration: 0.5)) {
                        showSummary = false
                    }
                }
            }
            .onAppear {
                //getImageColorIfNeeded()
                bgColor = (article.sentiment?.color ?? .clear).opacity(0.5)
                showSummary = selected
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
                if let sentimentIcon = article.sentiment?.icon {
                    Text(sentimentIcon)
                        .font(.title)
                }
                Text(subject)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background((article.sentiment?.color ?? .clear).opacity(0.1))
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    var summaryView: some View {
        if let summary = article.summary, showSummary {
            Text(summary)
                .customAttribute(EmphasisAttribute())
                .font(.title2)
                .multilineTextAlignment(.leading)
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(AppearanceTextTransition())
        }
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

#Preview {
    ArticleCardView(article: entity, selected: true)
        .frame(maxWidth: .infinity)
}


private let entity = EntityArticle(
    id: 0,
    createdAt: .now,
    updatedAt: .now,
    title: "달러·원, 관세 여파로 낙폭 확대...1,453원대 마감",
    url: "https://www.ytn.co.kr/_ln/0104_202504040413011740",
    image: "https://image.ytn.co.kr/general/jpg/2025/0404/202504040413011740_t.jpg",
    author: .init(),
    source: "YTN",
    description: "트럼프 미국 대통령의 상호 관세 폭탄으로 미국의 경기 침체 우려가 고조되면서 달러 약세를 끌어내 달러-원 환율이 야간 시간대 낙폭을 더욱 확대해 1,453원대에 마감했...",
    summary: "트럼프 미국 대통령의 상호 관세 폭탄으로 미국의 경기 침체 우려가 고조되면서 달러 약세가 발생하여 달러-원 환율이 1,453원대에 마감했다. 달러-원 환율은 전날보다 13.1원 하락했으며, 미국의 경기 침체 공포로 인해 한때 1,450.5원까지 떨어졌다. 주요 통화에 대한 달러 가치는 2.5% 급락하며 101.261로 내려갔고, 다른 통화 환율도 변동을 보였다.",
    mainSubject: "트럼프 관세로 인한 달러 약세",
    sentiment: .negative,
)
