//
//  CameraService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/01/28.
//

import AVFoundation
import Combine
import CoreImage
import CoreVideo
import Foundation

private let T = #fileID

public class CameraService {
    public enum AccessStatus {
        case notDetermined
        case denied
        case restricted
        case authroized
    }

    public struct Config {
        public let cameraPosition: AVCaptureDevice.Position
        public let captureAudio: Bool
        public let captureQRCode: CGRect?
        public let resolution: Resolution
        
        public enum Resolution: Int {
            case `default` = 0
            case HD = 921_600       // 1280 * 720
            case FHD = 2_073_600    // 1920 * 1080
            case UHD = 8_294_400    // 3840 * 2160
            
            var sessionPreset: AVCaptureSession.Preset {
                switch self {
                case .default: return .high
                case .HD: return .hd1280x720
                case .FHD: return .hd1920x1080
                case .UHD: return .hd4K3840x2160
                }
            }
        }

        public init(cameraPosition: AVCaptureDevice.Position,
                    captureAudio: Bool = false,
                    captureQRCode: CGRect? = nil,
                    resolution: Resolution = .default)
        {
            self.cameraPosition = cameraPosition
            self.captureAudio = captureAudio
            self.captureQRCode = captureQRCode
            self.resolution = resolution
        }
    }

    public private(set) var accessStatus: AccessStatus = .notDetermined
    public private(set) var isStarted = false

    private var config = Config(cameraPosition: .back)


    private var session: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var audioOutput: AVCaptureAudioDataOutput?

    private lazy var videoOutputDelegate = CameraServiceVideoCaptureDelegate()
    private lazy var videoOutputQueue = DispatchQueue.global()
    private lazy var audioOutputDelegate = CameraServiceAudioCaptureDelegate()
    private lazy var audioOutputQueue = DispatchQueue.global()
    private lazy var metaOutputDelegate = CameraServiceMetaCaptureDelegate()

    public var videoBufferSubject = CurrentValueSubject<CMSampleBuffer?, Never>(nil)
    public var audioBufferSubject = CurrentValueSubject<CMSampleBuffer?, Never>(nil)
    public var metaSubject = PassthroughSubject<URL, Never>()
    
    public private(set) var startTime: UInt64 = 0

    public static let shared = CameraService()

    private init() {}

    public func start(config: Config) async throws {
        self.config = config
        try await checkAccess()
        await stop()
        
        do {
            try configure()
        } catch {
            "failed to config camera service : \(error)".le(T)
            throw error
        }
        
        videoOutput?.setSampleBufferDelegate(videoOutputDelegate, queue: videoOutputQueue)
        audioOutput?.setSampleBufferDelegate(audioOutputDelegate, queue: audioOutputQueue)
        session?.startRunning()

        startTime = AppTimeRecorder.getMsec()
        isStarted = true
        "Started".ld(T)
    }

    public func stop() async {
        guard let session else { return }

        if session.isRunning {
            session.stopRunning()
        }
        
        self.session = nil
        isStarted = false
        
        "Stopped".ld(T)
    }

    public func checkAccess() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { authorized in
                    if !authorized {
                        "Camera access not authorized".le(T)
                        self.accessStatus = .denied
                        continuation.resume(throwing: AppError.accessDenied())
                        return
                    }
                    if self.config.captureAudio {
                        AVCaptureDevice.requestAccess(for: .audio) { authorized in
                            if !authorized {
                                "Mic access not authorized".le(T)
                                self.accessStatus = .denied
                                continuation.resume(throwing: AppError.accessDenied())
                                return
                            }
                            "Camera and Mic access authorized".li(T)
                            self.accessStatus = .authroized
                            continuation.resume()
                        }
                    }
                }

            case .restricted:
                "Camera and Mic access restricted".le(T)
                accessStatus = .restricted
                continuation.resume(throwing: AppError.accessDenied())

            case .denied:
                "Camera and Mic access denied".le(T)
                accessStatus = .denied
                continuation.resume(throwing: AppError.accessDenied())

            case .authorized:
                "Camera and Mic access authorized".li(T)
                accessStatus = .authroized
                continuation.resume()

            @unknown default:
                "Camera access authorization state unknown".lf(T)
                accessStatus = .notDetermined
                continuation.resume(throwing: AppError.accessDenied())
            }
        }
    }
    
    private func findBestFormat(for device: AVCaptureDevice, targetWidthHeight: Int) -> AVCaptureDevice.Format? {
        var bestFormat: AVCaptureDevice.Format?
        var closestDifference = Int.max
        var maxFPS: Float64 = 0.0

        for format in device.formats {
            let formatDescription = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)

            let currentArea = Int(dimensions.width * dimensions.height)
            let areaDifference = abs(currentArea - targetWidthHeight)

            if let fpsRange = format.videoSupportedFrameRateRanges.first {
                let currentMaxFPS = fpsRange.maxFrameRate
                if areaDifference <= closestDifference && currentMaxFPS >= maxFPS {
                    bestFormat = format
                    closestDifference = areaDifference
                    maxFPS = currentMaxFPS
                }
            }
        }

        return bestFormat
    }

    private func configure() throws {
        guard session == nil else { return }

        session = AVCaptureSession()
        guard let session = session else {
            "Failed to create AV capture session".le(T)
            throw AppError.generalError("Cannot initialize camera.")
        }

        session.beginConfiguration()
        session.usesApplicationAudioSession = true
        session.automaticallyConfiguresApplicationAudioSession = false
        defer { session.commitConfiguration() }

        let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTripleCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInTrueDepthCamera]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: config.cameraPosition)
        let devices = discoverySession.devices
        guard !devices.isEmpty, let videoDevice = devices.first(where: { $0.position == config.cameraPosition }) else {
            "No video devices available for position : \(config.cameraPosition).".le(T)
            throw AppError.generalError("Cannot initialize camera.")
        }
        "VIDEO DEVICE : \(videoDevice)".ld(T)
        if config.resolution != .default, let bestFormat = findBestFormat(for: videoDevice, targetWidthHeight: config.resolution.rawValue) {
            "FORMAT : \(bestFormat)".ld(T)
            try videoDevice.lockForConfiguration()
            videoDevice.activeFormat = bestFormat
            videoDevice.unlockForConfiguration()
        }
        self.videoDevice = videoDevice

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            guard session.canAddInput(videoInput) else {
                "Cannot add video input".le(T)
                throw AppError.generalError("Cannot initialize camera.")
            }
            session.addInput(videoInput)
            
            if config.resolution != .default, session.canSetSessionPreset(config.resolution.sessionPreset) {
                session.sessionPreset = config.resolution.sessionPreset
            }
        } catch {
            "Failed to add video input : \(error)".le(T)
            throw AppError(error)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        guard session.canAddOutput(videoOutput) else {
            "Cannot add video output".le(T)
            throw AppError.generalError("Cannot initialize camera.")
        }
        session.addOutput(videoOutput)
        
        self.videoOutput = videoOutput

        if config.captureAudio {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                "No audio devices available.".le(T)
                throw AppError.generalError("Cannot initialize camera.")
            }
            
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                guard session.canAddInput(audioInput) else {
                    "Cannot add audio input".le(T)
                    throw AppError.generalError("Cannot initialize camera.")
                }
                session.addInput(audioInput)
            } catch {
                "Failed to add AV input : \(error)".le(T)
                throw AppError(error)
            }
            
            let audioOutput = AVCaptureAudioDataOutput()
            guard session.canAddOutput(videoOutput), session.canAddOutput(audioOutput) else {
                "Cannot add audio output".le(T)
                throw AppError.generalError("Cannot initialize camera.")
            }
            session.addOutput(audioOutput)
            
            self.audioOutput = audioOutput
        }

        // TODO: configurable?
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = config.cameraPosition == .back
        }

        "Configured".ld(T)
    }
    
    public func setZoom(scale: CGFloat, animated: Bool) -> CGFloat {
        guard let videoDevice else { return 1 }
        do {
            try videoDevice.lockForConfiguration()
            let maxZoomFactor = videoDevice.activeFormat.videoMaxZoomFactor
            let zoomFactor = min(max(scale, 1), maxZoomFactor)
            //"zoom : \(zoomFactor) vs \(maxZoomFactor)".ld(T)
            
            if animated {
                videoDevice.ramp(toVideoZoomFactor: scale, withRate: 3)
            } else {
                videoDevice.videoZoomFactor = zoomFactor
            }
            videoDevice.unlockForConfiguration()
            return zoomFactor
        } catch {
            "failed to set zoom : \(error)".le(T)
            return 1
        }
    }
    
    public func turnFlash(_ on: Bool) -> Bool {
        guard let videoDevice, videoDevice.hasTorch else { return false }
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.torchMode = on ? .on : .off
            videoDevice.unlockForConfiguration()
        } catch {
            "failed to set flash : \(error)".le(T)
            return false
        }
        return videoDevice.torchMode == .on
    }

    @MainActor
    fileprivate func pushVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        videoBufferSubject.value = sampleBuffer
    }

    @MainActor
    fileprivate func pushAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        audioBufferSubject.value = sampleBuffer
    }
    
    @MainActor
    fileprivate func pushMeta(_ url: URL) {
        metaSubject.send(url)
    }
}

class CameraServiceVideoCaptureDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
//        let now = AppTimeRecorder.getMsec()
//        let startTime = CameraService.shared.startTime
//        "Video : \(now - startTime)".ld(T)
        Task { @MainActor in
            CameraService.shared.pushVideoSampleBuffer(sampleBuffer)
        }
    }

    public func captureOutput(_: AVCaptureOutput, didDrop _: CMSampleBuffer, from _: AVCaptureConnection) {
        // "video drop".le(T)
    }
}

class CameraServiceAudioCaptureDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
//        let now = AppTimeRecorder.getMsec()
//        let startTime = CameraService.shared.startTime
//        "Audio : \(now - startTime)".ld(T)
        Task { @MainActor in
            CameraService.shared.pushAudioSampleBuffer(sampleBuffer)
        }
    }
}

class CameraServiceMetaCaptureDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let meta = metadataObjects.compactMap({ $0 as? AVMetadataMachineReadableCodeObject }).first(where: { $0.type == .qr }),
              let url = URL(fromString: meta.stringValue)
        else {
            return
        }
        Task { @MainActor in
            CameraService.shared.pushMeta(url)
        }
    }
}
