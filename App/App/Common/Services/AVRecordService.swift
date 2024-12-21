//
//  AVRecordService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/02/05.
//

import AVFoundation
import Combine
import CoreImage
import Foundation

private let T = #fileID

extension AVRecordService {
    enum Const {
        static let tempFilePrefix = "AVRecordService_"
    }
}

// FIXME: to actor!!
public class AVRecordService: NSObject {
    private var assetWriter: AVAssetWriter?

    private var videoInput: AVAssetWriterInput?
    private var videoInputAdaptor: AVAssetWriterInputPixelBufferAdaptor?

    private var audioInput: AVAssetWriterInput?

    private var outputURL: URL?

    private var videoStartTime: CMTime?
    private var audioStartTime: CMTime?

    public var isRecording: Bool {
        assetWriter != nil
    }

    /// public share CIContext.
    public private(set) var ciContext: CIContext?

    public static let shared = AVRecordService()

    override private init() {
        ciContext = CIContext()
    }

    private func clear() {
        assetWriter = nil

        videoInput = nil
        videoInputAdaptor = nil

        audioInput = nil

        outputURL = nil

        videoStartTime = nil
        audioStartTime = nil
    }

    public func clearTempDirectory() {
        let fileManager = FileManager.default
        do {
            let folderPath = try fileManager.getFolderPath(for: .documentDirectory, in: .userDomainMask)
            let directoryContents = try fileManager.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil)
            // "FILES \(folderPath): \(directoryContents)".ld(T)
            try directoryContents
                .map { ($0, $0.lastPathComponent) }
                .filter { $0.1.contains(Const.tempFilePrefix) }
                .forEach {
                    "DELETE FILE : \($0.0), \($0.1)".ld(T)
                    try fileManager.removeItem(at: $0.0)
                }
        } catch {
            "Failed to delete directory : \(error)".le(T)
        }
    }

    public func start(outputSize: CGSize, pixelFormat _: OSType?) async throws -> URL {
        await stop()

        "Starting AV recording... output size = \(outputSize)".ld(T)

//        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//        CVPixelBufferCreate(kCFAllocatorDefault,
//                            Int(outputSize.width),
//                            Int(outputSize.height),
//                            pixelFormat ?? kCVPixelFormatType_32BGRA,
//                            attrs,
//                            &pixelBuffer)
//        guard pixelBuffer != nil else {
//            throw AppError.generalError("Cannot start record.")
//        }

        // let folderPath = try FileManager.default.getOrCreateFolderPath(for: .documentDirectory, in: .userDomainMask, pathComponent: Const.folderName)
        let folderPath = try FileManager.default.getOrCreateFolderPath(for: .documentDirectory, in: .userDomainMask)
        let outputURL = folderPath.appendingPathComponent("\(Const.tempFilePrefix)\(AppTimeRecorder.getMsec()).mov")

        guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else {
            throw AppError.generalError("Cannot start record.")
        }
        // need?
        assetWriter.shouldOptimizeForNetworkUse = true

        let videoSettings = [AVVideoCodecKey: AVVideoCodecType.hevc,
                             AVVideoWidthKey: outputSize.width,
                             AVVideoHeightKey: outputSize.height] as [String: Any]
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)

        let videoAdaptorAttr = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCMPixelFormat_32BGRA)]
        let videoInputAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: videoAdaptorAttr)
        guard assetWriter.canAdd(videoInput) else {
            "cannot add video input".le(T)
            throw AppError.generalError("Cannot start record.")
        }
        assetWriter.add(videoInput)

        let audioSettings = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                             AVNumberOfChannelsKey: 2,
                             AVSampleRateKey: 44100,
                             AVEncoderBitRateKey: 192_000] as [String: Any]
        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        audioInput.expectsMediaDataInRealTime = true
        guard assetWriter.canAdd(audioInput) else {
            "cannot add audio input".le(T)
            throw AppError.generalError("Cannot start record.")
        }
        assetWriter.add(audioInput)

        if assetWriter.startWriting() == false {
            "failed to start writing".le(T)
            throw AppError.generalError("Cannot start record.")
        }

        self.assetWriter = assetWriter
        self.videoInput = videoInput
        self.videoInputAdaptor = videoInputAdaptor
        self.audioInput = audioInput

        self.outputURL = outputURL

        assetWriter.startSession(atSourceTime: CMTime.zero)
        "Record started : url = \(outputURL)".ld(T)

        return outputURL
    }

    public func stop() async {
        "Record stop".ld(T)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task {
                if let assetWriter = assetWriter {
                    videoInput?.markAsFinished()
                    audioInput?.markAsFinished()
                    await assetWriter.finishWriting()
                    "Record finished? : \(assetWriter.status.rawValue)".ld(T)

                    clear()
                }
                continuation.resume()
            }
        }
    }

    public func write(video sampleBuffer: CMSampleBuffer, flip: Bool = false) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                guard isRecording,
                      let videoInput = videoInput,
                      let videoInputAdaptor = videoInputAdaptor
                else {
                    continuation.resume(throwing: AppError.notInited())
                    return
                }
                guard videoInput.isReadyForMoreMediaData else {
                    "wrtie not available temporarily. skip".le(T)
                    continuation.resume()
                    return
                }
                let pixelBuffer: CVPixelBuffer?
                if flip {
                    pixelBuffer = sampleBuffer.imageBuffer?.flip()
                } else {
                    pixelBuffer = sampleBuffer.imageBuffer
                }
                guard let pixelBuffer = pixelBuffer else {
                    return
                }

                var frameTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                if videoStartTime == nil {
                    videoStartTime = frameTime
                }
                if let startTime = videoStartTime {
                    frameTime.value -= startTime.value
                }
                // "VIDEO TIME : \(Double(frameTime.value) / Double(frameTime.timescale))".ld(T)

                if videoInputAdaptor.append(pixelBuffer, withPresentationTime: frameTime) == false {
                    continuation.resume(throwing: AppError.generalError("Failed to write video frame : status = \(o: assetWriter?.status.rawValue), error = \(o: assetWriter?.error)".le(T)))
                    return
                }

                continuation.resume()
            }
        }
    }

    public func write(audio sampleBuffer: CMSampleBuffer) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                guard isRecording,
                      let audioInput = audioInput
                else {
                    continuation.resume(throwing: AppError.notInited())
                    return
                }
                guard audioInput.isReadyForMoreMediaData else {
                    "wrtie not available temporarily. skip".le(T)
                    continuation.resume()
                    return
                }

                var frameTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                if audioStartTime == nil {
                    audioStartTime = frameTime
                }
                if let startTime = audioStartTime {
                    frameTime.value -= startTime.value
                }
                // "AUDIO TIME : \(Double(frameTime.value) / Double(frameTime.timescale))".ld(T)

                var count: CMItemCount = 0
                CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: 0, arrayToFill: nil, entriesNeededOut: &count)
                var info = [CMSampleTimingInfo](repeating: CMSampleTimingInfo(duration: CMTimeMake(value: 0, timescale: 0),
                                                                              presentationTimeStamp: CMTimeMake(value: 0, timescale: 0),
                                                                              decodeTimeStamp: CMTimeMake(value: 0, timescale: 0)),
                                                count: count)
                CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: count, arrayToFill: &info, entriesNeededOut: &count)

                for i in 0 ..< count {
                    info[i].decodeTimeStamp = frameTime
                    info[i].presentationTimeStamp = frameTime
                }

                var soundbuffer: CMSampleBuffer?

                CMSampleBufferCreateCopyWithNewTiming(allocator: kCFAllocatorDefault,
                                                      sampleBuffer: sampleBuffer,
                                                      sampleTimingEntryCount: count,
                                                      sampleTimingArray: &info,
                                                      sampleBufferOut: &soundbuffer)
                if let soundbuffer = soundbuffer {
                    audioInput.append(soundbuffer)
                }

                continuation.resume()
            }
        }
    }
}

// MARK: - utility functions

import PhotosUI

public extension AVRecordService {
    static func saveVideoIntoLibrary(videoUrl: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
                }) { saved, error in
                    if let error = error {
                        "Failed to save video to library : \(videoUrl), \(error)".le(T)
                        continuation.resume(throwing: AppError(error))
                        return
                    }
                    if !saved {
                        "not saved into library : \(videoUrl)".le(T)
                        continuation.resume(throwing: AppError.generalError("Cannot save to library."))
                        return
                    }

                    "Video saved to library : \(videoUrl)".ld(T)
                    continuation.resume()
                }
            }
        }
    }
}
