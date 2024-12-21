//
//  UIApplication+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/03/05.
//

import UIKit

extension UIApplication: @retroactive UIGestureRecognizerDelegate {
    public func addKeyboardDismissTapGesture() {
        guard let window = keyWindow else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        tapGesture.name = "keyboardDismissTap"
        window.addGestureRecognizer(tapGesture)
    }
    
    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        false
    }
    
    public var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}
