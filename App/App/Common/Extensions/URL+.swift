//
//  URL+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/02/11.
//

import Foundation

public extension URL {
    init?(fromString str: String?) {
        if let str = str, let val = URL(string: str) {
            self = val
        } else {
            return nil
        }
    }

    var fileSize: UInt64? {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: absoluteString)
            return attrs[.size] as? UInt64
        } catch {
            return nil
        }
    }
}
