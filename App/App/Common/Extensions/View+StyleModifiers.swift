//
//  View+StyleModifiers.swift
//  App
//
//  Created by Yongsik Kim on 5/23/25.
//

import SwiftUI

// MARK: -
public extension View {
    func borderedCapsule(cornerRadius: CGFloat = 12, strokeColor: Color, strokeWidth: CGFloat = 1) -> some View {
        modifier(BorderedCapsuleModifier(cornerRadius: cornerRadius, strokeColor: strokeColor, strokeWidth: strokeWidth))
    }
}

private struct BorderedCapsuleModifier: ViewModifier {
    let cornerRadius: CGFloat
    let strokeColor: Color
    let strokeWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            }
    }
}

