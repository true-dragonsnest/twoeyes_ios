//
//  String+Emoji.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2/18/24.
//

import Foundation

// MARK: - random emoji

private extension NSObject {
    var asPointer: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
}

private let contiguousEmoji: [UnicodeScalar] = {
    let ranges: [ClosedRange<Int>] = [
        0x1f600...0x1f64f,
        0x1f680...0x1f6c5,
        0x1f6cb...0x1f6d2,
        0x1f6e0...0x1f6e5,
        0x1f6f3...0x1f6fa,
        0x1f7e0...0x1f7eb,
        0x1f90d...0x1f93a,
        0x1f93c...0x1f945,
        0x1f947...0x1f971,
        0x1f973...0x1f976,
        0x1f97a...0x1f9a2,
        0x1f9a5...0x1f9aa,
        0x1f9ae...0x1f9ca,
        0x1f9cd...0x1f9ff,
        0x1fa70...0x1fa73,
        0x1fa78...0x1fa7a,
        0x1fa80...0x1fa82,
        0x1fa90...0x1fa95,
    ]

    return ranges.reduce([], +).map { UnicodeScalar($0)! }
}()

private extension UnsafeMutableRawPointer {
    var asEmoji: String {
        // Inspired by https://gist.github.com/iandundas/59303ab6fd443b5eec39
        let index = abs(self.hashValue) % contiguousEmoji.count
        return String(contiguousEmoji[index])
    }
}

public extension String {
    static func randomEmoji() -> String {
        return NSObject().asPointer.asEmoji
    }
}

// MARK: - to image

import UIKit
public extension String {
    func textToImage(fontSize: CGFloat = 1024) -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: fontSize)
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        //UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIGraphicsBeginImageContext(imageSize)
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}
