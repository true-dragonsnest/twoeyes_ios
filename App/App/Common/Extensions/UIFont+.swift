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
    
    static func preferredFont(for style: TextStyle, weight: Weight, italic: Bool = false) -> UIFont {
        let traits = UITraitCollection(preferredContentSizeCategory: .large)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style, compatibleWith: traits)
        
        var font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        if italic {
            font = font.with([.traitItalic])
        }
        
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: font)
    }
    
    private func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
