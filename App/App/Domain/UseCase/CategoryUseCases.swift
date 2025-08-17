//
//  CategoryUseCases.swift
//  App
//
//  Created by Assistant on 8/15/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Categories {}
}

extension UseCases.Categories {
    static func getCategories(languageCode: String = Locale.current.language.languageCode?.identifier ?? "en") async throws -> [EntityCategory] {
        struct Response: Codable {
            let categories: [EntityCategory]
            let languageCode: String?
            let total: Int
        }
        
        do {
            let decoder = BackEnd.Functions.decoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let url = BackEnd.Functions.getCategories(languageCode: languageCode).url
            
            let response: Response = try await HttpApiService.shared.get(
                from: url,
                decoder: decoder,
                logLevel: 1
            )
            
            "got categories : \(o: response.jsonPrettyPrinted)".ld(T)
            return response.categories
        } catch {
            "failed to get categories : \(error)".le(T)
            throw error
        }
    }
}
