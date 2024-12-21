//
//  Array+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/07/10.
//

import CloudKit
import Foundation

public extension Array {
    mutating func pop() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }

    mutating func pop(maxCount: Int) -> [Element] {
        var ret: [Element] = []
        (0 ..< maxCount).forEach { _ in
            if let ad = self.pop() {
                ret.append(ad)
            }
        }
        return ret
    }
}
