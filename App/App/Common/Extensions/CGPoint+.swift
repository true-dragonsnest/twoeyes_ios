//
//  CGPoint+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/01/23.
//

import Foundation

public extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func + (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    static func - (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
}

public extension CGPoint {
    func distance(from point: CGPoint) -> Double {
        let xd = (point.x - x)
        let yd = (point.y - y)
        return sqrt(xd * xd + yd * yd)
    }
}
