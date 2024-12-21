//
//  UIColor+.swift
//  Nest0
//
//  Created by Yongsik Kim on 2021/07/15.
//

import UIKit

public extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Int = 255) {
        let r = min(max(red, 0), 255)
        let g = min(max(green, 0), 255)
        let b = min(max(blue, 0), 255)
        let a = min(max(alpha, 0), 255)
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }

    convenience init(fromHexString hex: String) {
        let s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().replacingOccurrences(of: "#", with: "")
        var argb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&argb)
        self.init(Int((argb & 0x00FF_0000) >> 16), Int((argb & 0x0000_FF00) >> 8), Int(argb & 0x0000_00FF), Int((argb & 0xFF00_0000) >> 24))
    }

    func hexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(format: "#%02lX%02lX%02lX%02lX", lroundf(Float(a * 255)), lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }

    static func random() -> UIColor {
        UIColor(Int.random(in: 0 ... 255), Int.random(in: 0 ... 255), Int.random(in: 0 ... 255), Int.random(in: 0 ... 255))
    }
    
    func toImage(of size: CGSize) -> UIImage? {
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        UIGraphicsBeginImageContext(size)
        context.setFillColor(self.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
