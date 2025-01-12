//
//  TextRecognitionUseCase.swift
//  App
//
//  Created by Yongsik Kim on 1/12/25.
//

import SwiftUI
import VisionKit
import Vision

private let T = #fileID

/// this sucks. to not use this.
extension UseCases {
    enum TextRecognition {
        static func execute(_ image: UIImage) async throws {
            guard let cgImage = image.cgImage else {
                throw AppError.invalidRequest("invalid image".le(T))
            }
            
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                let requestHandler = VNImageRequestHandler(cgImage: cgImage)
                let request = VNRecognizeTextRequest { request, error in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        cont.resume(throwing: AppError.invalidResponse("perform VN failed".le(T)))
                        return
                    }
                    
                    let recognizedStrings = observations.compactMap { observation in
                        return observation.topCandidates(1).first?.string
                    }
                    "recognition : \(recognizedStrings)".ld(T)
                    cont.resume()
                }
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                //request.automaticallyDetectsLanguage = true
                request.recognitionLanguages = ["ko"]
                
                do {
                    try requestHandler.perform([request])
                } catch {
                    "failed to perform VN request : \(error)".le(T)
                    cont.resume(throwing: error)
                }
            }
        }
    }
}
