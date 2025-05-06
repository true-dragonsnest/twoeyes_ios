//
//  ThreadCardView.swift
//  App
//
//  Created by Yongsik Kim on 5/4/25.
//

import SwiftUI
import Kingfisher

struct ThreadCardView: View {
    let thread: EntityThread
    
    @State var currentImageIndex = 0
    @State var timer: Timer? = nil
    
    @State var width: CGFloat = 4
    
    var body: some View {
        cardView
    }
    
    var cardView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(thread.mainSubject)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.label1)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                Spacer()
            }
            
            if thread.images?.isEmpty == false {
                imageCarousel
                    .cornerRadius(12)
                    .onAppear(perform: startImageTimer)
                    .onDisappear(perform: stopImageTimer)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.label3, lineWidth: 1)
        }
        .readSize { width = $0.width }
    }
    
    private var imageCarousel: some View {
        ZStack(alignment: .bottom) {
            if let images = thread.images, !images.isEmpty {
                if let url = URL(fromString: images[safe: currentImageIndex]) {
                    KFImage(url)
                        .backgroundDecode(true)
                        .resizable()
                        .placeholder {
                            Color.secondaryFill
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width - 4, height: width - 4)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal, 2)
                        .padding(.bottom, 2)
                }
            }
        }
    }
    
    func startImageTimer() {
        guard let images = thread.images, images.count > 1 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut) {
                currentImageIndex = (currentImageIndex + 1) % images.count
            }
        }
    }
    
    func stopImageTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ThreadCardView(thread: testThread)
        .frame(width: 200, height: 260)
}

private let testThread: EntityThread = .init(
    id: 0,
    createdAt: .now,
    updatedAt: .now,
    title: "thread 1",
    mainSubject: "헌법재판소법 개정안 통과 통과 통과통과통과통과통과통과통과통과통과통과통과통과통과통과통과통과통과통과통과",
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

