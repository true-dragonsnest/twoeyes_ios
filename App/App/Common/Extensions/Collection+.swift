//
//  Collection+.swift
//  Nest0
//
//  Created by Yongsik Kim on 2021/09/02.
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
