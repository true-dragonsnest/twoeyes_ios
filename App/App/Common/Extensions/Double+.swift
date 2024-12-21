//
//  Double+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/12/31.
//

import Foundation

public extension Double {
    func shortString(_ decimalPlaces: Int) -> String {
        String(format: "%.\(decimalPlaces)f", self)
    }

    init?(fromString str: String?) {
        if let str = str, let val = Double(str) {
            self = val
        } else {
            return nil
        }
    }
}
