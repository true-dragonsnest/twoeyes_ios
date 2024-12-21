//
//  Mirror+.swift
//  Nest1
//
//  Created by Yongsik Kim on 2022/01/01.
//

import Foundation

public extension Mirror {
    var properties: [(String, Child)] {
        children.reduce([(String, Child)]()) {
            guard let propertyName = $1.label else { return $0 }
            return $0 + [(propertyName, $1)]
        }
    }
}
