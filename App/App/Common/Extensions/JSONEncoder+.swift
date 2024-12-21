//
//  JSONEncoder+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/11/13.
//

import UIKit

// FIXME: why .ios8601 is not here???
public extension JSONEncoder {
    static let shared = JSONEncoder()
    static let iso8601 = JSONEncoder(dataEncodingStrategy: .base64 /* .iso8601 */ )
    static let iso8601PrettyPrinted = JSONEncoder(dataEncodingStrategy: .base64 /* .iso8601 */, outputFormatting: .prettyPrinted)
}

public extension JSONEncoder {
    convenience init(dataEncodingStrategy: DataEncodingStrategy = .base64,
                     outputFormatting: OutputFormatting = [],
                     keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys)
    {
        self.init()
        self.dataEncodingStrategy = dataEncodingStrategy
        self.outputFormatting = outputFormatting
        self.keyEncodingStrategy = keyEncodingStrategy
    }
}
