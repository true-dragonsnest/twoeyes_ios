//
//  EnvironmentValues.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/03/05.
//

import SwiftUI

public extension EnvironmentValues {
    var isPreview: Bool {
        #if DEBUG
            return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
            return false
        #endif
    }

    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetKey.self]
    }
}

private struct SafeAreaInsetKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUIInsets ?? EdgeInsets()
    }
}

private extension UIEdgeInsets {
    var swiftUIInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
