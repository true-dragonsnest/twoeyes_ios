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
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?
    let onSwipeUp: (() -> Void)?
    let onSwipeDown: (() -> Void)?
    
    init(article: EntityArticle,
         onSwipeLeft: (() -> Void)? = nil,
         onSwipeRight: (() -> Void)? = nil,
         onSwipeUp: (() -> Void)? = nil,
         onSwipeDown: (() -> Void)? = nil)
    {
        self.article = article
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeUp = onSwipeUp
        self.onSwipeDown = onSwipeDown
    }
    
    @State var width: CGFloat = 0
    @State var bgColor: Color = .clear

    private enum SwipeStatus {
        case none
        case left
        case right
        case up
        case down
    }
    @State var translation: CGSize = .zero
    @State private var swipeStatus: SwipeStatus = .none
    @State var hasPassedThreshold: Bool = false

    let horizontalSwipeThreshold: CGFloat = 120
    let verticalSwipeThreshold: CGFloat = 100
    let minSwipeDistance: CGFloat = 15
    
    let lightImpact = UIImpactFeedbackGenerator(style: .light)
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        cardView
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(Double(translation.width / 20)))
            .scaleEffect(verticalScaleEffect)
            .gesture(swipeGesture)
            .overlay(
                ZStack {
                    // Horizontal swipe overlays
                    Image(systemName: "hand.thumbsdown.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.label1, .red)
                        .font(.system(size: 100))
                        .opacity(swipeStatus == .left ? min(abs(translation.width) / 100, 1.0) : 0)
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "hand.thumbsup.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.label1, .green)
                        .font(.system(size: 100))
                        .opacity(swipeStatus == .right ? min(translation.width / 100, 1.0) : 0)
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // Vertical swipe overlays
                    Image(systemName: "arrow.up.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.label1, .blue)
                        .font(.system(size: 100))
                        .opacity(swipeStatus == .up ? min(abs(translation.height) / 100, 1.0) : 0)
                        .padding(.top, 16)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    Image(systemName: "arrow.down.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.label1, .purple)
                        .font(.system(size: 100))
                        .opacity(swipeStatus == .down ? min(abs(translation.height) / 100, 1.0) : 0)
                        .padding(.bottom, 16)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            )
            .onAppear {
                prepareHaptics()
            }
    }
    
    var verticalScaleEffect: CGFloat {
        if swipeStatus == .up || swipeStatus == .down {
            return max(0.95, 1.0 - abs(translation.height) / 1000)
        }
        return 1.0
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
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(bgColor, lineWidth: 1)
            }
            .readSize {
                width = $0.width
            }
            .onAppear {
                loadColorIfNeeded()
            }
    }
    
    var contentView: some View {
        VStack {
            titleView
                .padding(.horizontal)
                .padding(.top)
            
            if let imageUrl = URL(fromString: article.image) {
                let width = max(0, self.width - 8 * 2)
                KFImage(imageUrl)
                    .backgroundDecode(true)
                    .resizable()
                    .placeholder {
                        Color.red
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width)
                    .clipShape(.rect(cornerRadius: 8))
                    .padding(.horizontal, 8)
            }
            
            Spacer()
        }
        .aspectRatio(9 / 16, contentMode: .fit)
    }
    
    var titleView: some View {
        HStack {
            Text(article.title ?? "")
                .font(.title2)
                .bold()
                .foregroundStyle(.label1)
            Spacer()
        }
    }
    
    func loadColorIfNeeded() {
        guard bgColor == .clear, let imageUrl = article.image else { return }
        Task {
            guard let image = try? await UseCases.Download.image(from: imageUrl),
                  let color = image.dominantColor else { return }
            bgColor = Color(uiColor: color)
        }
    }
}

// MARK: - Gesture Handlers
extension ArticleCardView {
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: minSwipeDistance)
            .onChanged { gesture in
                handleDragChanged(gesture)
            }
            .onEnded { gesture in
                // Only process if we actually moved the card
                if translation != .zero {
                    handleDragEnded(gesture)
                }
            }
    }
    
    private func handleDragChanged(_ gesture: DragGesture.Value) {
        // Determine if this is predominantly a horizontal or vertical gesture
        let horizontalAmount = abs(gesture.translation.width)
        let verticalAmount = abs(gesture.translation.height)
        
        if horizontalAmount > verticalAmount * 1.5 {
            // Predominantly horizontal swipe
            translation = CGSize(width: gesture.translation.width, height: 0)
            updateHorizontalSwipeStatus()
        } else if verticalAmount > horizontalAmount * 1.5 {
            // Predominantly vertical swipe
            translation = CGSize(width: 0, height: gesture.translation.height)
            updateVerticalSwipeStatus()
        } else {
            // Mixed movement - let's determine the dominant direction
            if horizontalAmount > verticalAmount {
                translation = CGSize(width: gesture.translation.width, height: 0)
                updateHorizontalSwipeStatus()
            } else {
                translation = CGSize(width: 0, height: gesture.translation.height)
                updateVerticalSwipeStatus()
            }
        }
        
        checkThresholdCrossing()
    }
    
    private func handleDragEnded(_ gesture: DragGesture.Value) {
            switch swipeStatus {
            case .left, .right:
                if abs(translation.width) > horizontalSwipeThreshold {
                    completeHorizontalSwipe()
                } else {
                    resetCardPosition()
                }
                
            case .up, .down:
                if abs(translation.height) > verticalSwipeThreshold {
                    completeVerticalSwipe()
                } else {
                    resetCardPosition()
                }
                
            case .none:
                resetCardPosition()
            }
            
            hasPassedThreshold = false
        }
        
        private func updateHorizontalSwipeStatus() {
            if translation.width > 0 {
                swipeStatus = .right
            } else if translation.width < 0 {
                swipeStatus = .left
            }
        }
        
        private func updateVerticalSwipeStatus() {
            if translation.height < 0 {
                swipeStatus = .up
            } else if translation.height > 0 {
                swipeStatus = .down
            }
        }
        
        private func checkThresholdCrossing() {
            let currentThreshold: CGFloat
            let currentTranslation: CGFloat
            
            switch swipeStatus {
            case .left, .right:
                currentThreshold = horizontalSwipeThreshold
                currentTranslation = abs(translation.width)
            case .up, .down:
                currentThreshold = verticalSwipeThreshold
                currentTranslation = abs(translation.height)
            case .none:
                return
            }
            
            if currentTranslation > currentThreshold && !hasPassedThreshold {
                hasPassedThreshold = true
                triggerHaptic(.medium)
            } else if currentTranslation < currentThreshold && hasPassedThreshold {
                hasPassedThreshold = false
            }
        }
        
        private func completeHorizontalSwipe() {
            // Animate card off-screen horizontally
            withAnimation(.easeOut) {
                translation = CGSize(
                    width: translation.width > 0 ? 500 : -500,
                    height: 0
                )
            }
            
            // Haptic feedback
            triggerHaptic(.heavy)
            
            // Trigger callback
            if translation.width > 0 {
                onSwipeRight?()
            } else {
                onSwipeLeft?()
            }
        }
        
        private func completeVerticalSwipe() {
            // Animate card off-screen vertically
            withAnimation(.easeOut) {
                translation = CGSize(
                    width: 0,
                    height: translation.height < 0 ? -500 : 500
                )
            }
            
            // Haptic feedback
            triggerHaptic(.heavy)
            
            // Trigger callback
            if translation.height < 0 {
                onSwipeUp?()
            } else {
                onSwipeDown?()
            }
        }
        
        private func resetCardPosition() {
            // Reset position with spring animation
            withAnimation(.spring()) {
                translation = .zero
                swipeStatus = .none
            }
            
            // Haptic feedback with delay
            if translation != .zero {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    triggerHaptic(.light)
                }
            }
        }
        
        private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
            switch style {
            case .light:
                lightImpact.impactOccurred()
            case .medium:
                mediumImpact.impactOccurred()
            case .heavy:
                heavyImpact.impactOccurred()
            default:
                lightImpact.impactOccurred()
            }
        }
        
        private func prepareHaptics() {
            lightImpact.prepare()
            mediumImpact.prepare()
            heavyImpact.prepare()
        }
}

// MARK: - get dominant color from image
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    var dominantColor: UIColor? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        filter.extent = ciImage.extent
        
        let context = CIContext()
        guard let filtered = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)    // RGBA
        context.render(
            filtered,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: .init(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        
        return .init(red: CGFloat(bitmap[0]) / 255.0,
                     green: CGFloat(bitmap[1]) / 255.0,
                     blue: CGFloat(bitmap[2]) / 255.0,
                     alpha: CGFloat(bitmap[3]) / 255.0)
    }
}

