//
//  FaviconUseCases.swift
//  App
//
//  Created by Assistant on 1/11/25.
//

import Foundation
import UIKit

private let T = #fileID

extension UseCases {
    enum Favicon {}
}

extension UseCases.Favicon {
    static func loadFavicon(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString),
              let host = url.host else { return nil }
        
        let faviconURLs = [
            URL(string: "https://\(host)/apple-touch-icon.png"),
            URL(string: "https://\(host)/apple-touch-icon-precomposed.png"),
            URL(string: "https://\(host)/apple-touch-icon-180x180.png"),
            URL(string: "https://\(host)/favicon-32x32.png"),
            URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64"),
            URL(string: "https://\(host)/favicon.ico"),
            URL(string: "https://www.google.com/s2/favicons?domain=\(host)")
        ].compactMap { $0 }
        
        var bestImage: UIImage?
        var bestSize: CGFloat = 0
        
        await withTaskGroup(of: UIImage?.self) { group in
            for faviconURL in faviconURLs {
                group.addTask {
                    await fetchFavicon(from: faviconURL)
                }
            }
            
            for await image in group {
                if let image = image {
                    let size = max(image.size.width, image.size.height)
                    if size > bestSize {
                        bestImage = image
                        bestSize = size
                    }
                }
            }
        }
        
        return bestImage
    }
    
    private static func fetchFavicon(from url: URL) async -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = UIImage(data: data) else {
                return nil
            }
            
            return image
        } catch {
            return nil
        }
    }
}