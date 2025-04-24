//
//  ExploreView.swift
//  App
//
//  Created by Yongsik Kim on 3/8/25.
//

import SwiftUI

private let T = #fileID

struct ExploreView: View {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    @State var repo: ArticleRepo = .init()
    
    @State var dragProgress = 0.0
    @State var selectedIndex = 0
    @State var containerSize = CGSize.zero
    
    @State var verticalOffset: CGFloat = 0
    @State var hasPassedReactionThreshold = false
    
    let minReactionDistance: CGFloat = 50
    let reactionThreshold: CGFloat = 150
    let reactionImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        contentView
    }
    
    @ViewBuilder
    var contentView: some View {
        if repo.articles.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .label3))
        } else {
            ZStack {
                ForEach(repo.articles) { article in
                    let index = article.index ?? 0
                    if abs(selectedIndex - index) < 5 {
                        ArticleCardView(article: article)
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .zIndex(zIndex(for: index))
                            .offset(x: xOffset(for: index))
                            .scaleEffect(scale(for: index))
                            .rotationEffect(.degrees(rotation(for: index)))
                            .shadow(color: shadow(for: index), radius: 30, y: 20)
                            .offset(y: index == selectedIndex ? verticalOffset : 0)
                            .overlay {
                                likeOverlay
                            }
                    }
                }
            }
            .readSize {
                containerSize = $0
            }
            .highPriorityGesture(gesture)
            .sensoryFeedback(.impact(flexibility: .rigid), trigger: selectedIndex)
        }
    }
    
    @ViewBuilder
    var likeOverlay: some View {
        let amount = min((abs(verticalOffset) - minReactionDistance) / reactionThreshold, 1.0)
        ZStack {
            Image(systemName: "hand.thumbsup.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.label1, .green)
                .font(.system(size: 100))
                .opacity(verticalOffset < -minReactionDistance ? amount : 0)
                .scaleEffect(amount)
            
            Image(systemName: "hand.thumbsdown.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.label1, .red)
                .font(.system(size: 100))
                .opacity(verticalOffset > minReactionDistance ? amount : 0)
                .scaleEffect(amount)
        }
        .offset(y: verticalOffset)
    }
    
    var gesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                self.dragProgress = -(value.translation.width / containerSize.width)
                
// FUCK
//                let verticalAmount = value.translation.height
//                self.verticalOffset = verticalAmount
                
                checkReactionThresholdCrossing()
            }
            .onEnded { value in
                snapToNearestIndex()
                hasPassedReactionThreshold = false
            }
    }
    
    func checkReactionThresholdCrossing() {
        let offset = abs(verticalOffset)
        if offset > reactionThreshold && !hasPassedReactionThreshold {
            hasPassedReactionThreshold = true
            reactionImpact.impactOccurred()
        } else if offset < reactionThreshold && hasPassedReactionThreshold {
            hasPassedReactionThreshold = false
        }
    }
    
    // FIXME: here, Invalid sample AnimatablePair
    func snapToNearestIndex() {
        let threshold = 0.3
        if abs(dragProgress) < threshold {
            withAnimation(.bouncy) {
                self.dragProgress = 0.0
                self.verticalOffset = 0
            }
        } else {
            let direction = dragProgress < 0 ? -1 : 1
            withAnimation(.smooth(duration: 0.25)) {
                go(to: selectedIndex + direction)
            }
        }
    }
    
    func go(to index: Int) {
        let maxIndex = repo.articles.count - 1
        if index > maxIndex {
            self.selectedIndex = maxIndex
        } else if index < 0 {
            self.selectedIndex = 0
        } else {
            self.selectedIndex = index
        }
        self.dragProgress = 0
        self.verticalOffset = 0
    }
    
    var progressIndex: Double {
        dragProgress + Double(selectedIndex)
    }
    
    func currentPosition(for index: Int) -> Double {
        progressIndex - Double(index)
    }
    
    func zIndex(for index: Int) -> Double {
        let position = currentPosition(for: index)
        return -abs(position)
    }
    
    func xOffset(for index: Int) -> Double {
        let padding = containerSize.width / 10
        let x = (Double(index) - progressIndex) * padding
        let maxIndex = repo.articles.count - 1
        // position > 0 && position < 0.99 && index < maxIndex
        if index == selectedIndex && progressIndex < Double(maxIndex) && progressIndex > 0 {
            return x * swingOutMultiplier
        }
        return x
    }
    
    var swingOutMultiplier: Double {
        return abs(sin(Double.pi * progressIndex) * 20)
    }
    
    func scale(for index: Int) -> CGFloat {
        return 1.0 - (0.1 * abs(currentPosition(for: index)))
    }
    
    func rotation(for index: Int) -> Double {
        return -currentPosition(for: index) * 2
    }
    
    func shadow(for index: Int) -> Color {
//        guard shadowDisabled == false else {
//            return .clear
//        }
        let index = Double(index)
        let progress = 1.0 - abs(progressIndex - index)
        let opacity = 0.3 * progress
        return .black.opacity(opacity)
    }
}

