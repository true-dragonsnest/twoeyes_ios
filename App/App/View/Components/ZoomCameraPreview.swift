//
//  ZoomCameraPreview.swift
//  Nest3
//
//  Created by Yongsik Kim on 9/8/24.
//

import Combine
import SwiftUI
import AVFoundation

private let T = #fileID

// MARK: - view
struct ZoomCameraPreview: View {
    @ObservedObject var viewModel: ZoomCameraPreviewModel

    var body: some View {
        Group {
            if let cameraImage = viewModel.cameraImage {
                Image(decorative: cameraImage, scale: 1, orientation: .upMirrored)
                    .resizable()
                    .overlay(alignment: .bottom) {
                        zoomScaleView
                    }
            } else {
                Color.clear
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { scale in
                    viewModel.setZoomScale(min(scale * viewModel.lastZoomScale, Const.maxZoomScale), animated: false)
                }
                .onEnded { scale in
                    viewModel.commitZoomScale()
                }
        )
    }
    
    // FIXME: front camera case
    var zoomScaleView: some View {
        Text(String(format: "%.1f", viewModel.zoomScale / 2) + "x")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.white)
            .frame(width: 32, height: 32)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .padding()
            .onTapGesture {
                let targetZoom: CGFloat = viewModel.zoomScale > 2 ? 2 : (viewModel.zoomScale == 2 ? 1 : (viewModel.zoomScale > 1 ? 1 : 2))
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.setZoomScale(targetZoom, animated: true)
                viewModel.commitZoomScale()
            }
    }
}

// MARK: - view model
class ZoomCameraPreviewModel: ObservableObject {
    let aspectRatio: CGFloat
    var onImageCaptured: ((UIImage) -> Void)?
    
    init(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
    }
    
    @Published var flashOn = false
    @Published var frontCamera = false
    
    @Published fileprivate(set) var zoomScale: CGFloat = Const.defaultZoomScale
    @Published fileprivate(set) var lastZoomScale: CGFloat = Const.defaultZoomScale
    
    @Published fileprivate(set) var cameraImage: CGImage?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    func start() {
        CameraService.shared.videoBufferSubject.sink { [weak self] sampleBuffer in
            guard let self,
                  let sampleBuffer,
                  let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                  let cgImage = CGImage.create(from: pixelBuffer)
            else { return }

            let w = CGFloat(cgImage.width)
            let h = CGFloat(cgImage.height)
            let cropHeight = w / self.aspectRatio;
            let cropped = cgImage.cropping(to: .init(origin: .init(x: 0, y: (h - cropHeight) / 2),
                                                     size: .init(width: w, height: cropHeight)))
            DispatchQueue.main.async {
                if self.cameraImage == nil {
                    withAnimation {
                        self.cameraImage = cropped
                    }
                } else {
                    self.cameraImage = cropped
                }
            }
        }
        .store(in: &subscriptions)
        
        Task {
            await startCamera()
            "ZoomCameraPreview started".li(T)
        }
    }
    
    func stop() {
        subscriptions.removeAll()
        Task {
            await stopCamera()
            "ZoomCameraPreview stopped".li(T)
        }
    }
    
    func capture() {
        guard let cameraImage else { return }
        onImageCaptured?(UIImage(cgImage: cameraImage).withHorizontallyFlippedOrientation())
    }
    
    @MainActor
    func toggleFlash() {
        guard frontCamera == false else { return }
        flashOn.toggle()
        _ = CameraService.shared.turnFlash(flashOn)
    }
    
    @MainActor
    func toggleCamera() {
        frontCamera.toggle()
        if frontCamera {
            flashOn = false
        }
        Task {
            await startCamera()
        }
    }
    
    private func startCamera() async {
        do {
            try await CameraService.shared.start(config: .init(cameraPosition: frontCamera ? .front : .back, captureAudio: false))
            _ = CameraService.shared.turnFlash(flashOn)
            await MainActor.run {
                zoomScale = CameraService.shared.setZoom(scale: Const.defaultZoomScale, animated: false)
                lastZoomScale = zoomScale
            }
        } catch {
            ContentViewModel.shared.error = AppError.accessDenied("failed to start camera : \(error)".le(T))
        }
    }
    
    private func stopCamera() async {
        await CameraService.shared.stop()
    }
    
    @MainActor
    fileprivate func setZoomScale(_ scale: CGFloat, animated: Bool) {
        zoomScale = CameraService.shared.setZoom(scale: scale, animated: animated)
    }
    
    @MainActor
    fileprivate func commitZoomScale() {
        lastZoomScale = zoomScale
    }
}

// MARK: - consts
private enum Const {
    static let defaultZoomScale: CGFloat = 2.0
    static let maxZoomScale: CGFloat = 12
}
