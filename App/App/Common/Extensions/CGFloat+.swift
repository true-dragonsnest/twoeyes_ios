//
//  CGFloat+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/01/23.
//

import Foundation

public extension CGFloat {
    func shortString(_ decimalPlaces: Int) -> String {
        String(format: "%.\(decimalPlaces)f", self)
    }
}
