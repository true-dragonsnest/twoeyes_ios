//
//  Spacing.swift
//  App
//
//  Created by Yongsik Kim on 1/7/25.
//

import SwiftUI

// MARK: - Dynamic Type Support
// Usage in View:
// @StateObject private var spacing = DynamicSpacing()
// @StateObject private var padding = DynamicPadding()
// Then use: spacing.m, padding.l, etc.

class DynamicSpacing: ObservableObject {
    @ScaledMetric(relativeTo: .body) private var xsBase: CGFloat = 2
    @ScaledMetric(relativeTo: .body) private var sBase: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var mBase: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var lBase: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var xlBase: CGFloat = 24
    @ScaledMetric(relativeTo: .body) private var xxlBase: CGFloat = 32
    
    var xs: CGFloat { xsBase }
    var s: CGFloat { sBase }
    var m: CGFloat { mBase }
    var l: CGFloat { lBase }
    var xl: CGFloat { xlBase }
    var xxl: CGFloat { xxlBase }
}

class DynamicPadding: ObservableObject {
    @ScaledMetric(relativeTo: .body) private var xsBase: CGFloat = 4
    @ScaledMetric(relativeTo: .body) private var sBase: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var mBase: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var lBase: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var xlBase: CGFloat = 24
    @ScaledMetric(relativeTo: .body) private var xxlBase: CGFloat = 32
    @ScaledMetric(relativeTo: .body) private var horizontalBase: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var verticalBase: CGFloat = 12
    
    var xs: CGFloat { xsBase }
    var s: CGFloat { sBase }
    var m: CGFloat { mBase }
    var l: CGFloat { lBase }
    var xl: CGFloat { xlBase }
    var xxl: CGFloat { xxlBase }
    var horizontal: CGFloat { horizontalBase }
    var vertical: CGFloat { verticalBase }
}

// MARK: - Static Values (Legacy Support)
// For existing code that doesn't need Dynamic Type

enum Spacing {
    static let xs: CGFloat = 2
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum Padding {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    
    static let horizontal: CGFloat = 16
    static let vertical: CGFloat = 12
}