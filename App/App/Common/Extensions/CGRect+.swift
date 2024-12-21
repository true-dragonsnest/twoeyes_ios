//
//  CGRect+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 8/18/24.
//

import UIKit

public extension CGRect {
    var center: CGPoint {
        return .init(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}
