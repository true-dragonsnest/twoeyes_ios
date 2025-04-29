//
//  AddNewsView.swift
//  App
//
//  Created by Yongsik Kim on 2/16/25.
//

import SwiftUI

struct AddNewsView: View {
    @State var url: String = ""
    @State var inProgress = false
    @State var next = false
    
    @State var article: EntityArticle?
    @State var threads: [EntityThread]?
    
    @FocusState var focused: Bool
        
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack {
                inputView
                    .padding(.horizontal)
                
                if article != nil {
                    Spacer()
                        .border(.yellow)
                }
            }
            
            if let article {
                ArticleCardView(article: article, selected: true)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(0.7)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
            
            if inProgress {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
            }
        }
        .overlay(alignment: .bottom) {
            if next {
                Button {
                    withAnimation {
                    }
                } label: {
                    Text("Add")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(.appPrimary)
                        .clipShape(.rect(cornerRadius: 24))
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    var inputView: some View {
        VStack(spacing: 20) {
            Text("Post a news")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.label2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                TextField("Enter news URL", text: $url)
                    .foregroundStyle(.label1)
                    .font(.headline)
                    .onSubmit {
                        "submit : \(url)".ld()
                        addArticle()
                    }
                    .focused($focused)
                    .submitLabel(.go)
                    .padding()
                    .background(Color.primaryFill)
                    .clipShape(.rect(cornerRadius: 24))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.label3, lineWidth: 1)
                    }
                
                Button {
                    let pasteboard = UIPasteboard.general
                    if pasteboard.hasStrings {
                        url = pasteboard.string ?? ""
                        focused = true
                    }
                } label: {
                    Text("Paste")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding()
                        .background(.appPrimary)
                        .clipShape(.rect(cornerRadius: 24))
                }
            }
        }
    }
    
    func addArticle() {
        guard url.isEmpty == false else { return }
        
        Task {
            await MainActor.run { inProgress = true }
            
            do {
                // FUCK: let article = try await UseCases.Articles.post(url: url)
                let article = testArticle
                await MainActor.run {
                    withAnimation {
                        self.article = article
                    }
                }
                
                // FUCK: guard let articleId = article.id else { return }
                let articleId = 802
                let threads = try await UseCases.Threads.findSimilar(to: articleId)
            } catch {
                ContentViewModel.shared.error = error
            }
            await MainActor.run { inProgress = false }
        }
    }
}

#Preview {
    AddNewsView()
}

private let testArticle = EntityArticle(
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
