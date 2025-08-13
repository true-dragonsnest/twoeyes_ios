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
                    .padding(.horizontal, Padding.s)
                    .padding(.top, Padding.s)
                Spacer()
            }
            
            Spacer()
            
            if thread.articleSnapshots?.isEmpty == false {
                imageCarousel
                    .cornerRadius(12)
                    .onAppear(perform: startImageTimer)
                    .onDisappear(perform: stopImageTimer)
            }
        }
        .background(.ultraThinMaterial)
        .borderedCapsule(cornerRadius: 12, strokeColor: .label3)
        .readSize { width = max(4, $0.width) }
    }
    
    private var imageCarousel: some View {
        ZStack(alignment: .bottom) {
            if let snapshots = thread.articleSnapshots, !snapshots.isEmpty {
                let images = snapshots.compactMap { $0.image }
                if !images.isEmpty, let url = URL(fromString: images[safe: currentImageIndex]) {
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
                }
            }
        }
    }
    
    func startImageTimer() {
        guard let snapshots = thread.articleSnapshots, 
              !snapshots.isEmpty else { return }
        let images = snapshots.compactMap { $0.image }
        guard images.count > 1 else { return }
        
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

