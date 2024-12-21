//
//  UIScreen+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/03/01.
//

import Foundation
import UIKit

public extension UIScreen {
    // static let mainSize = main.bounds
    static var mainSize: CGSize {
        guard let mainWindow = UIApplication.shared.keyWindow else { return .zero }
        return mainWindow.screen.bounds.size
    }

    static let mainWidth = mainSize.width
    static let mainHeight = mainSize.height
}
