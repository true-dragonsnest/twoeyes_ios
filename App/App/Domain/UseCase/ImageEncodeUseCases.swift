//
//  ImageEncodeUseCases.swift
//  App
//
//  Created by Yongsik Kim on 1/5/25.
//

import CoreImage
import UIKit

private let T = #fileID

extension UseCases {
    enum ImageEncode {
        struct Result {
            let data: Data
            let filename: String    // name + ext
            let mime: String
        }
    }
}

extension UseCases.ImageEncode {
    static func encode(_ image: UIImage, name: String) -> Result? {
        if image.isHeicSupported, let data = image.heic {
            return .init(data: data, filename: name + ".heic", mime: "image/heic")
        }
        if let data = image.jpegData(compressionQuality: 0.8) {
            return .init(data: data, filename: name + ".jpg", mime: "image/jpeg")
        }
        return nil
    }
}
