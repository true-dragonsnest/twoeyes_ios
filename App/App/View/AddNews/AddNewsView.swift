//
//  AddNewsView.swift
//  App
//
//  Created by Yongsik Kim on 2/16/25.
//

import SwiftUI

struct AddNewsView: View {
    @State var url: String?
    
    @State var initialAnimation = false
    @State var titleProgress: CGFloat = 0
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 40) {
                Text("Share a news")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.label2)
                    .blurOpacityEffect(initialAnimation)
                
                Text("add.news.prompt")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(Color.label1)
                    .multilineTextAlignment(.center)
                    .textRenderer(TitleTextRenderer(progress: titleProgress))
                
                Text("Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, Blah, ")
                    .font(.callout)
                    .foregroundStyle(Color.label2)
                    .multilineTextAlignment(.center)
                    .blurOpacityEffect(initialAnimation)
            }
            .padding(.horizontal)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.35))
            
            withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                initialAnimation = true
            }
            
            withAnimation(.smooth(duration: 2.5, extraBounce: 0).delay(0.3)) {
                titleProgress = 1
            }
        }
    }
}

extension View {
    func blurOpacityEffect(_ show: Bool) -> some View {
        self
            .blur(radius: show ? 0 : 2)
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.9)
    }
}
