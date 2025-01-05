//
//  DownloadUseCases.swift
//  App
//
//  Created by Yongsik Kim on 1/5/25.
//

import SwiftUI

private let T = #fileID

extension UseCases {
    enum Download {}
}

extension UseCases.Download {
    static func image(from url: String) async throws -> UIImage {
        do {
            let data: Data = try await HttpApiService.shared.get(from: url)
            guard let image = UIImage(data: data) else {
                throw AppError.invalidResponse("failed to decode image".le(T))
            }
            return image
        } catch {
            "download image failed from url : \(url) : \(error)".le(T)
            throw error
        }
    }
}
