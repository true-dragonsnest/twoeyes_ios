//
//  ImageFetchUseCases.swift
//  App
//
//  Created by Assistant on 1/14/25.
//

import Foundation
import UIKit
import Kingfisher

private let T = #fileID

extension UseCases {
    enum ImageFetch {}
}

extension UseCases.ImageFetch {
    static func fetch(from url: URL) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    continuation.resume(returning: imageResult.image)
                case .failure(let error):
                    "failed to fetch image from \(url) : \(error)".le(T)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    static func prefetch(urls: [URL]) {
        let prefetcher = ImagePrefetcher(urls: urls)
        prefetcher.start()
    }
    
    static func clearCache() async {
        await withCheckedContinuation { continuation in
            ImageCache.default.clearCache {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    static func cancelDownloadTask(for imageView: UIImageView) {
        imageView.kf.cancelDownloadTask()
    }
}
