//
//  YoutubeAudioExtractUseCase.swift
//  App
//
//  Created by Yongsik Kim on 1/28/25.
//

import Foundation
import AVFoundation
import Photos

private let T = #fileID

extension UseCases {
    enum AudioExtract {
        enum ExtractionError: Error {
            case accessDenied
            case videoNotFound
            case exportFailed(String)
            case invalidAsset
        }
        
        static func extract(from videoAsset: PHAsset,
                            progressHandler: ((Float) -> Void)? = nil) async throws -> URL
        {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            guard status == .authorized else {
                "access not granted".le(T)
                throw ExtractionError.accessDenied
            }
            
            return try await withCheckedThrowingContinuation { continuation in
                let options = PHVideoRequestOptions()
                options.version = .current
                options.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestAVAsset(
                    forVideo: videoAsset,
                    options: options
                ) { asset, _, _ in
                    guard let asset else {
                        "invalid asset".le(T)
                        continuation.resume(throwing: ExtractionError.invalidAsset)
                        return
                    }
                    
                    guard let exportSession = AVAssetExportSession(
                        asset: asset,
                        presetName: AVAssetExportPresetAppleM4A
                    ) else {
                        continuation.resume(throwing: ExtractionError.exportFailed("Could not create export session".le(T)))
                        return
                    }
                    
                    let outputURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension("m4a")
                    
                    try? FileManager.default.removeItem(at: outputURL)
                    
                    exportSession.outputURL = outputURL
                    exportSession.outputFileType = .m4a
                    exportSession.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
                    
                    exportSession.exportAsynchronously {
                        DispatchQueue.main.async {
                            switch exportSession.status {
                            case .completed:
                                "completed".ld(T)
                                continuation.resume(returning: outputURL)
                                
                            case .failed:
                                let error = exportSession.error?.localizedDescription ?? "Unknown error"
                                continuation.resume(throwing: ExtractionError.exportFailed(error.le(T)))
                                
                            case .cancelled:
                                continuation.resume(throwing: ExtractionError.exportFailed("Export cancelled".le(T)))
                                
                            default:
                                continuation.resume(throwing: ExtractionError.exportFailed("Unknown status".le(T)))
                            }
                        }
                    }
                    
                    // FIXME: test if this works
                    if let progressHandler {
                        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                            let progress = exportSession.progress
                            progressHandler(progress)
                            
                            if exportSession.status != .exporting {
                                timer.invalidate()
                            }
                        }
                        progressTimer.fire()
                    }
                    //$
                }
            }
        }
    }
}


