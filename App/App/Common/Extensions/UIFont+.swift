//
//  UIFont+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/06/14.
//

import UIKit

public extension UIFont {
    convenience init?(fromFontNames fontNames: [String], ofSize size: CGFloat) {
        if fontNames.count == 1 {
            self.init(name: fontNames[0], size: size)
            return
        }

        var fontDescriptors = fontNames.compactMap { UIFont(name: $0, size: size)?.fontDescriptor }
        guard fontDescriptors.count > 1 else {
            return nil
        }

        let firstDescr = fontDescriptors.removeFirst()
        let descr = firstDescr.addingAttributes([.cascadeList: fontDescriptors])

        self.init(descriptor: descr, size: size)
    }
}
