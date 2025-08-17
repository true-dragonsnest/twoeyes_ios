//
//  NERSentimentBadge.swift
//  App
//
//  Created by Assistant on 1/14/25.
//

import SwiftUI

struct NERSentimentBadge: View {
    let entity: String
    let sentiment: Float
    let reasoning: String?
    @State private var showReasoning = false
    
    private var intensity: CGFloat {
        min(CGFloat(abs(sentiment)), 1.0)
    }
    
    private var color: Color {
        intensity < 0.3 ? .clear : (sentiment > 0 ? Color.blue : Color.red)
    }
    
    private let threshold: Float = 0.5
    
    var body: some View {
        HStack(spacing: 6) {
            Text(entity)
                .font(.subheadline)
                .fontWeight(intensity > 0.6 ? .bold : .medium)
                .foregroundStyle(.label1)
            
            if sentiment > threshold {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.caption)
                    .foregroundStyle(.label1)
                    .scaleEffect(1 + intensity * 0.3)
                    .shadow(color: .label1.opacity(0.5), radius: intensity * 3)
            } else if sentiment < -threshold {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.caption)
                    .foregroundStyle(.label1)
                    .scaleEffect(1 + intensity * 0.3)
                    .shadow(color: .label1.opacity(0.5), radius: intensity * 3)
            }
        }
        .padding(.horizontal, Padding.s * (1 + intensity * 0.3))
        .padding(.vertical, Padding.s)
        .background(.thinMaterial)
        .background(color.opacity(intensity))
        .borderedCapsule(cornerRadius: 24,
                         strokeColor: color == .clear ? .label3 : color,
                         strokeWidth: 1 + intensity)
        .onTapGesture {
            if let reasoning = reasoning, !reasoning.isEmpty {
                showReasoning = true
            }
        }
        .popover(isPresented: $showReasoning) {
            Text(reasoning ?? "")
                .font(.caption)
                .foregroundStyle(.label1)
                .padding(.horizontal, Padding.m)
                .padding(.vertical, Padding.s)
                .frame(maxWidth: 200)
                .presentationCompactAdaptation(.popover)
        }
    }
}
