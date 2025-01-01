//
//  GeminiApiUseCases.swift
//  App
//
//  Created by Yongsik Kim on 12/24/24.
//

import SwiftUI
import GoogleGenerativeAI

private let T = #fileID

extension UseCases {
    enum GeminiApi {
        static let model = "gemini-1.5-flash"
        
        struct Response: Codable {
            let text: String
            let inputTokenCount: Int
            let outputTokenCount: Int
        }
        
        static func generate(with image: UIImage,
                             systemPrompt: String,
                             userPrompt: String,
                             responseMIMEType: String = "text/plain",
                             temperature: Float = 0.7) async throws -> Response
        {
            let config = GenerationConfig(temperature: temperature,
                                          topP: 0.95,
                                          topK: 40,
                                          responseMIMEType: responseMIMEType)
            let genModel = GenerativeModel(name: model,
                                           apiKey: AppKey.geminiApiKey,
                                           generationConfig: config,
                                           systemInstruction: systemPrompt)
            let response = try await genModel.generateContent(userPrompt, image)
            //"Response : \(response)".ld(T)
            guard let text = response.candidates.first?.content.parts.first?.text else {
                throw AppError.invalidResponse("No text response : \(response)".le(T))
            }
            let ret = Response(text: text,
                               inputTokenCount: response.usageMetadata?.promptTokenCount ?? 0,
                               outputTokenCount: response.usageMetadata?.candidatesTokenCount ?? 0)
            "response : \(o: ret.jsonPrettyPrinted)".ld(T)
            return ret
        }
    }
}
