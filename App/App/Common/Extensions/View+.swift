//
//  View+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/08/16.
//

import SwiftUI

/// programmable modifier
public extension View {
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// size reader
public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value _: inout CGSize, nextValue _: () -> CGSize) {}
}

/// to any view
public extension View {
    func anyView() -> AnyView {
        AnyView(self)
    }
}
