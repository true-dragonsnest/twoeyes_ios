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
        //static let model = "gemini-2.0-flash-exp"
        
        struct Result: Codable {
            let text: String
            let inputTokenCount: Int
            let outputTokenCount: Int
        }
        
        static func generate(with image: UIImage,
                             systemPrompt: String,
                             userPrompt: String = "",
                             responseMIMEType: String = "text/plain",
                             temperature: Float = 0.7) async throws -> Result
        {
            let config = GenerationConfig(temperature: temperature,
                                          topP: 0.95,
                                          topK: 40,
                                          maxOutputTokens: 8192 * 4,
                                          responseMIMEType: responseMIMEType)
            let genModel = GenerativeModel(name: model,
                                           apiKey: AppKey.geminiApiKey,
                                           generationConfig: config,
                                           systemInstruction: systemPrompt)
            let response = try await genModel.generateContent(userPrompt, image)
            "Generate : \(systemPrompt), \(userPrompt)".ld(T)
            //"Response : \(response)".ld(T)
            guard let text = response.candidates.first?.content.parts.first?.text else {
                throw AppError.invalidResponse("No text response : \(response)".le(T))
            }
            let ret = Result(text: text,
                             inputTokenCount: response.usageMetadata?.promptTokenCount ?? 0,
                             outputTokenCount: response.usageMetadata?.candidatesTokenCount ?? 0)
            "response : \(o: ret.jsonPrettyPrinted)".ld(T)
            return ret
        }
        
//        private struct Request: Codable {
//            var contents: [Content]
//            var generationConfig: GenerationConfig?
//            
//            struct Content: Codable {
//                var parts: [Part]
//                
//                struct Part: Codable {
//                    var text: String?
//                    var inlineData: InlineData?
//                    
//                    struct InlineData: Codable {
//                        var data: String
//                        var mimeType: String
//                    }
//                }
//            }
//            
//            struct GenerationConfig: Codable {
//                var temperature: Float?
//                var topP: Float?
//                var topK: Int?
//                var stopSequences: [String]?
//                var mxOutputTokens: Int?
//            }
//        }
//        
//        private struct Response: Codable {
//            let candidates: [Candidate]
//            let usageMetadata: UsageMetadata
//            
//            struct Candidate: Codable {
//                let content: Content
//                
//                struct Content: Codable {
//                    var parts: [Part]
//                    
//                    struct Part: Codable {
//                        var text: String?
//                    }
//                }
//            }
//            
//            struct UsageMetadata: Codable {
//                let promptTokenCount: Int
//                let candidatesTokenCount: Int
//                let totalTokenCount: Int
//            }
//        }
        
//        static func generate(with image: UIImage,
//                             systemPrompt: String,
//                             temperature: Float = 0.7) async throws -> Result
//        {
//            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//                throw AppError.invalidRequest("invalid image".le(T))
//            }
//            let base64 = imageData.base64EncodedString()
//            
//            let request: Request = .init(
//                contents: [
//                    .init(parts: [
//                        .init(text: systemPrompt),
//                        .init(inlineData: .init(data: base64, mimeType: "image/jpeg"))
//                    ])
//                ],
//                generationConfig: .init(
//                    temperature: temperature,
//                    topP: 0.95,
//                    topK: 40
//                )
//            )
//            let url = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(AppKey.geminiApiKey)"
//            
//            let response: Response = try await HttpApiService.shared.post(entity: request, to: url, logLevel: 2)
//            "Response : \(o: response.jsonPrettyPrinted)".ld(T)
//            guard let text = response.candidates.first?.content.parts.first?.text else {
//                throw AppError.invalidResponse("No text response : \(response)".le(T))
//            }
//            let ret = Result(text: text,
//                             inputTokenCount: response.usageMetadata.promptTokenCount,
//                             outputTokenCount: response.usageMetadata.candidatesTokenCount)
//            "result : \(o: ret.jsonPrettyPrinted)".ld(T)
//            return ret
//        }
    }
}
