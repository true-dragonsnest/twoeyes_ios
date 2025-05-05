//
//  AddNewsView.swift
//  App
//
//  Created by Yongsik Kim on 2/16/25.
//

import SwiftUI

struct AddNewsView: View {
    @State var url: String = ""
    
    @State var article: EntityArticle?
    @State var threadId: Int?
    
    @State var threads: [EntityThread]?
    @State var showThreads = false
//    @State var threads: [EntityThread] = testThreads
//    @State var showThreads = true
    
    @FocusState var focused: Bool
    @State var inProgress = false
        
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
                VStack {
                    ArticleCardView(article: article, selected: true)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(0.8)
                    
                    Spacer()
                    
                    Button {
                        loadThreads()
                    } label: {
                        Text("Next")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(.appPrimary)
                            .clipShape(.rect(cornerRadius: 24))
                    }
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
            if showThreads {
                VStack(spacing: 0) {
                    Spacer()
                    
                    threadListView
                        .padding(.vertical, 40)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadii: .init(topLeading: 24, bottomLeading: 0, bottomTrailing: 0, topTrailing: 24)))
                }
                .transition(.move(edge: .bottom))
                .zIndex(2)
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
    }
    
    var inputView: some View {
        VStack(spacing: 20) {
            Text("Post a news")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.label2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if article == nil {
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
    }
    
    var threadListView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Please select the thread to which this article will be added.")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.label1)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let threads {
                        ForEach(threads) { thread in
                            ThreadCardView(thread: thread, width: 200)
                        }
                    }
                    Color.background
                        .frame(width: 200, height: 200 + 60)
                        .overlay {
                            VStack(spacing: 12) {
                                Spacer()
                                Text("Create\na new thread.")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.label1)
                                    .multilineTextAlignment(.center)
                                "plus".iconButton(font: .title2, monochrome: .appPrimary)
                                    .bold()
                                Spacer()
                            }
                        }
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.label3, lineWidth: 1)
                        }
                }
                .padding(.horizontal, 16)
            }
            .scrollClipDisabled()
        }
    }
    
    func addArticle() {
        guard url.isEmpty == false else { return }
        
        Task {
            await MainActor.run {
                inProgress = true
                withAnimation {
                    self.article = nil
                    self.threadId = nil
                }
            }
            
            do {
                // FUCK: let article = try await UseCases.Articles.post(url: url)
                let article = testArticle
                await MainActor.run {
                    withAnimation {
                        self.article = article
                    }
                }
            } catch {
                ContentViewModel.shared.error = error
            }
            await MainActor.run { inProgress = false }
        }
    }
    
    func loadThreads() {
        guard let articleId = article?.id else { return }
        Task {
            await MainActor.run { inProgress = true }
            
            do {
                // FUCK: let threads = try await UseCases.Threads.findSimilar(to: articleId)
                await MainActor.run {
                    self.threads = testThreads
                    withAnimation {
                        showThreads = true
                    }
                }
            } catch {
                ContentViewModel.shared.error = error
            }
            
            await MainActor.run { inProgress = false }
        }
    }
    
    func commit() {
        
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

private let testThreads: [EntityThread] = [
    .init(
        id: 0,
        createdAt: .now,
        updatedAt: .now,
        title: "thread 1",
        mainSubject: "헌법재판소법 개정안 통과 통과통과통과통과통과통과통과통과통과",
        images: [
            "https://image.ytn.co.kr/general/jpg/2025/0417/202504171439380585_t.jpg",
            "https://pimg.mk.co.kr/news/cms/202504/17/rcv.YNA.20250417.PYH2025041712750001300_R.jpg",
            "https://file2.nocutnews.co.kr/newsroom/image/2025/04/09/202504091127263426_6.jpg",
            "http://news.kbs.co.kr/data/news/2025/04/18/20250418_0I1PVf.jpg"
          ],
        articleIds: [
            800,
            802,
            803,
            911
          ]
    )
]
    
