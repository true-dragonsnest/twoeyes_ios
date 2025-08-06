//
//  AppMediaType.swift
//  App
//
//  Created by Yongsik Kim on 8/5/25.
//

import Foundation

enum AppMediaType: String, CaseIterable {
    case jpeg
    case png
    case heic
    case heif
    case gif
    case webp
    case mp4
    case mov
    case aac
    
    var ext: String { "." + rawValue }
    var mime: String {
        switch self {
        case .jpeg: "image/jpeg"
        case .png: "image/png"
        case .heic: "image/heic"
        case .heif: "image/heif"
        case .gif: "image/gif"
        case .webp: "image/webp"
        case .mp4: "video/mp4"
        case .mov: "video/quicktime"
        case .aac: "audio/aac"
        }
    }
}

extension String {
    func withMediaExt(_ type: AppMediaType) -> String {
        self + type.ext
    }
}
