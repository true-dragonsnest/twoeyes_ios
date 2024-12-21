//
//  ShapeStyle+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/04/23.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
    static var random: Color {
        Color(red: .random(in: 0 ... 1), green: .random(in: 0 ... 1), blue: .random(in: 0 ... 1))
    }
}
