//
//  Customizable.swift
//  Nest0
//
//  Created by Yongsik Kim on 2021/07/15.
//

import Foundation

// a customization point of given Base type
public struct CustomizationPoint<BaseType> {
    public let baseType: BaseType
    public init(_ baseType: BaseType) {
        self.baseType = baseType
    }
}

// MARK: - .app domain

// protocol to make app customized version of BaseType
// ex) UIColor.app.*
public protocol Customizable {
    associatedtype BaseType

    static var app: CustomizationPoint<BaseType>.Type { get set }
    var app: CustomizationPoint<BaseType> { get set }
}

// Default implementation
public extension Customizable {
    static var app: CustomizationPoint<Self>.Type {
        get {
            CustomizationPoint<Self>.self
        }
        set {}
    }

    var app: CustomizationPoint<Self> {
        get {
            CustomizationPoint(self)
        }
        set {}
    }
}

// MARK: - DragonHeart internal

// protocol to make app customized version of BaseType
// ex) UIColor.dh.*
protocol DHCustomizable {
    associatedtype BaseType

    static var dh: CustomizationPoint<BaseType>.Type { get set }
    var dh: CustomizationPoint<BaseType> { get set }
}

// Default implementation
extension DHCustomizable {
    static var dh: CustomizationPoint<Self>.Type {
        get {
            CustomizationPoint<Self>.self
        }
        set {}
    }

    var dh: CustomizationPoint<Self> {
        get {
            CustomizationPoint(self)
        }
        set {}
    }
}
