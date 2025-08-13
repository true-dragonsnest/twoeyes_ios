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
            .onAppear(perform: startImageTimer)
            .onDisappear(perform: stopImageTimer)
    }
    
    var cardView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(thread.mainSubject)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.label1)
                    .padding(.horizontal, Padding.s)
                    .padding(.top, Padding.s)
                Spacer()
            }
            
            Spacer()
            
            if thread.articleSnapshots?.isEmpty == false {
                imageCarousel
                    .cornerRadius(12)
            }
        }
        .background(.ultraThinMaterial)
        .borderedCapsule(cornerRadius: 12, strokeColor: .label3)
        .readSize { width = max(4, $0.width) }
    }
    
    @ViewBuilder
    private var imageCarousel: some View {
        if let snapshots = thread.articleSnapshots, !snapshots.isEmpty {
            let images = snapshots.compactMap { $0.image }
            if !images.isEmpty {
                TabView(selection: $currentImageIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        if let url = URL(fromString: images[index]) {
                            KFImage(url)
                                .backgroundDecode(true)
                                .resizable()
                                .placeholder {
                                    Color.secondaryFill
                                }
                                .aspectRatio(contentMode: .fill)
                                .frame(width: width - 4, height: width - 4)
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.horizontal, Padding.xs)
                                .padding(.bottom, Padding.xs)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .allowsHitTesting(false)
                .frame(height: width - 4)
            }
        }
    }
    
    func startImageTimer() {
        guard let snapshots = thread.articleSnapshots, 
              !snapshots.isEmpty else { return }
        let images = snapshots.compactMap { $0.image }
        guard images.count > 1 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentImageIndex = (currentImageIndex + 1) % images.count
            }
        }
    }
    
    func stopImageTimer() {
        timer?.invalidate()
        timer = nil
    }
}

