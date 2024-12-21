//
//  CGSize+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/10/10.
//

import UIKit

public extension CGSize {
    var aspectRatio: CGFloat {
        height == 0 ? 1 : width / height
    }
}

public extension CGSize {
    static func + (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func - (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func * (lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func / (lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
