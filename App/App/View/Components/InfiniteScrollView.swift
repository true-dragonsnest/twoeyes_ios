//
//  InfiniteScrollView.swift
//  App
//
//  Created by Yongsik Kim on 2/16/25.
//

import SwiftUI

// from: https://www.youtube.com/watch?v=VHaPYUWFTF8

struct InfiniteScrollView<Content: View>: View {
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content
    
    @State var contentSize: CGSize = .zero

    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    Group(subviews: content) { collection in
                        HStack(spacing: spacing) {
                            ForEach(collection) { view in
                                view
                            }
                        }
                        .onGeometryChange(for: CGSize.self) {
                            $0.size
                        } action: { newValue in
                            contentSize = .init(width: newValue.width, height: newValue.height)
                        }
                        
                        // repeating content for infinite looping
                        let averageWidth = contentSize.width / CGFloat(collection.count)
                        let repeatingCount = contentSize.width > 0 ? Int((size.width / averageWidth).rounded()) + 1 : 1
                        
                        HStack(spacing: spacing) {
                            ForEach(0..<repeatingCount, id: \.self) { index in
                                let view = Array(collection)[index % collection.count]
                                view
                            }
                        }
                    }
                }
                .background(InfiniteScrollHelper(contentSize: $contentSize, decelerationRate: .constant(.fast)))
            }
        }
    }
}

private struct InfiniteScrollHelper: UIViewRepresentable {
    @Binding var contentSize: CGSize
    @Binding var decelerationRate: UIScrollView.DecelerationRate
    
    func makeCoordinator() -> Coordinator {
        Coordinator(decelerationRate: decelerationRate, contentSize: contentSize)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let scrollView = view.scrollView {
                context.coordinator.defaultDelegate = scrollView.delegate
                scrollView.decelerationRate = decelerationRate
                scrollView.delegate = context.coordinator
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.decelerationRate = decelerationRate
        context.coordinator.contentSize = contentSize
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var decelerationRate: UIScrollView.DecelerationRate
        var contentSize: CGSize
        
        init(decelerationRate: UIScrollView.DecelerationRate, contentSize: CGSize) {
            self.decelerationRate = decelerationRate
            self.contentSize = contentSize
        }
        
        weak var defaultDelegate: UIScrollViewDelegate?
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.decelerationRate = decelerationRate
            
            let minX = scrollView.contentOffset.x
            
            if minX > contentSize.width {
                scrollView.contentOffset.x -= contentSize.width
            }
            if minX < 0 {
                scrollView.contentOffset.x += contentSize.width
            }
            
            defaultDelegate?.scrollViewDidScroll?(scrollView)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            defaultDelegate?.scrollViewWillEndDragging?(
                scrollView,
                withVelocity: velocity,
                targetContentOffset: targetContentOffset)
        }
    }
}

private extension UIView {
    var scrollView: UIScrollView? {
        if let superview, superview is UIScrollView {
            return superview as? UIScrollView
        }
        
        return superview?.scrollView
    }
}


// MARK: - auto scroll + preview
private struct CardCarouselView: View {
    let cards: [String] = ["111111", "222222", "333333", "444444", "555555", "666666"]
    
    @State var scrollPosition: ScrollPosition = .init()
    @State var currentScrollOffset: CGFloat = 0
    @State var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    
    @State var scrollPhase: ScrollPhase = .idle
    
    var body: some View {
        VStack {
//            ScrollView(.horizontal) {
//                HStack(spacing: 10) {
//                    ForEach(cards, id: \.self) { card in
//                        cardView(card)
//                    }
//                }
//            }
            InfiniteScrollView {
                ForEach(cards, id: \.self) { card in
                    cardView(card)
                }
            }
            .scrollPosition($scrollPosition)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .containerRelativeFrame(.vertical) { value, _ in
                value * 0.45
            }
            .onScrollPhaseChange { _, newPhase in
                scrollPhase = newPhase
            }
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.x + $0.contentInsets.leading
            } action: { oldValue, newValue in
                currentScrollOffset = newValue
                
                if scrollPhase != .decelerating || scrollPhase != .animating {
                    // FIXME: 220 to item width
                    let activeIndex = Int((currentScrollOffset / 220).rounded()) % cards.count
                }
            }
        }
        .safeAreaPadding(15)
        .onReceive(timer) { _ in
            currentScrollOffset += 0.35
            scrollPosition.scrollTo(x: currentScrollOffset)
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
    
    @ViewBuilder func cardView(_ text: String) -> some View {
        GeometryReader {
            let size = $0.size
            
            Color.random
                .frame(width: size.width, height: size.height)
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
                .overlay {
                    Text(text)
                        .font(.title)
                        .lineLimit(1)
                }
        }
        .frame(width: 220)
        .scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
            content
                .offset(y: phase == .identity ? -10 : 0)
                .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
        }
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        CardCarouselView()
    }
}
