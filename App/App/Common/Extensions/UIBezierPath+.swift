//
//  UIBezierPath+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2/18/24.
//

import UIKit

public extension UIBezierPath {
    static func circularExclusionPath(with center: CGPoint, radius: CGFloat) -> [UIBezierPath] {
        let topHalf = UIBezierPath()
        topHalf.move(to: .init(x: center.x - radius, y: center.y - radius))
        topHalf.addLine(to: .init(x: center.x - radius, y: center.y))
        topHalf.addArc(withCenter: center, radius: radius, startAngle: .pi, endAngle: 0, clockwise: true)
        topHalf.addLine(to: .init(x: center.x + radius, y: center.y - radius))
        topHalf.close()
        
        let bottomHalf = UIBezierPath()
        bottomHalf.move(to: .init(x: center.x - radius, y: center.y + radius))
        bottomHalf.addLine(to: .init(x: center.x - radius, y: center.y))
        bottomHalf.addArc(withCenter: center, radius: radius, startAngle: .pi, endAngle: 0, clockwise: false)
        bottomHalf.addLine(to: .init(x: center.x + radius, y: center.y + radius))
        bottomHalf.close()
        
        return [topHalf, bottomHalf]
    }
}
