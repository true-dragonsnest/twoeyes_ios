//
//  Image+.swift
//  DragonHeart
//
//  Created by Eunhye Kim on 12/16/23.
//

import SwiftUI

public extension Image {
    @MainActor
    func getUIImage() -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
    
    func data(url:URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data:data)!)
                .resizable()
        }
        
        return self.resizable()
    }
}
