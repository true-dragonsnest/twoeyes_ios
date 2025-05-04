//
//  JSONDecoder+.swift
//  App
//
//  Created by Yongsik Kim on 5/4/25.
//

import Foundation

// MARK: - date formatting extension
extension JSONDecoder {
    var dateDecodingStrategyFormatters: [DateFormatter]? {
        get { return nil }
        set {
            guard let formatters = newValue else { return }
            self.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)
                
                for formatter in formatters {
                    if let date = formatter.date(from: string) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Date string does not match format expected by formatter."
                )
            }
        }
    }
}
