//
//  CGImage+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/02/05.
//

import VideoToolbox

public extension CGImage {
    static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
        guard let pixelBuffer = cvPixelBuffer else { return nil }
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
        return image
    }
}
