//
//  View+Modifiers.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2/20/24.
//

import SwiftUI

// MARK: - Text.fitToParent() : make Text view fit to given parent frame
public extension View {
    func fitToParent() -> some View {
        modifier(FitToParentModifier())
    }
}

private struct FitToParentModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 500))
            .minimumScaleFactor(0.01)
    }
}
