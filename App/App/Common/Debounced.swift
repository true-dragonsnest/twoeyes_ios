//
//  Debounced.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 12/11/23.
//

import SwiftUI
import Combine

public class Debounced<V>: ObservableObject {
    @Published public var value: V
    @Published public var debounced: V
    private var sub: Set<AnyCancellable> = []

    public init(_ initial: V, duration: TimeInterval) {
        self.value = initial
        self.debounced = initial
        $value
            .debounce(for: .seconds(duration), scheduler: RunLoop.main)
            .assign(to: \.debounced, on: self)
            .store(in: &sub)
    }
}
