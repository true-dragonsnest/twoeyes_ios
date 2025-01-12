//
//  NoteCaptureView.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

private let T = #fileID

struct NoteCaptureView: View {
    @EnvironmentObject var myHomeViewModel: MyHomeViewModel
    
    @StateObject var cameraPreviewModel = ZoomCameraPreviewModel(aspectRatio: 9 / 16, resolution: .UHD)
    @State var capturedImage: UIImage?
    @State var sendMode = false
    
    var body: some View {
        contentView
            .navigationTitle("Capture Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                clear()
                cameraPreviewModel.onImageCaptured = onImageCapture
                cameraPreviewModel.start()
            }
            .onDisappear {
                cameraPreviewModel.stop()
            }
            .preferredColorScheme(.dark)
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack {
                preview
                    .padding(.vertical)
                Spacer()
                controls
                    .padding(.bottom)
            }
        }
    }
    
    var preview: some View {
        Group {
            if let capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
            } else {
                ZoomCameraPreview(viewModel: cameraPreviewModel)
                    .overlay(alignment: .top) {
                        Text("note.capture.guide")
                            .font(.footnote)
                            .foregroundStyle(.label2)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(contentMode: .fit)
        .clipShape(.rect(cornerRadius: 16))
    }
    
    var controls: some View {
        HStack {
            Spacer()
            leadingButtons
            Spacer()
            CameraButton(sendMode: .constant(false), height: 80) {
                captureImage()
            }
            Spacer()
            trailingButtons
            Spacer()
        }
    }
    
    var leadingButtons: some View {
        Color.background
            .overlay {
                if sendMode {
                    cancelButton
                        .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                }
            }
            .frame(width: 60, height: 60)
            .clipped()
    }
    
    var trailingButtons: some View {
        Color.background
            .overlay {
                if sendMode {
                    nextButton
                        .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .frame(width: 60, height: 60)
            .clipped()
    }
    
    var cancelButton: some View {
        "xmark".iconButton(font: .title, monochrome: .label1) {
            clear()
        }
        .padding()
    }
    
    var nextButton: some View {
        "chevron.forward".iconButton(font: .title, monochrome: .label1) {
            send()
        }
        .padding()
    }
}

// MARK: - actions
extension NoteCaptureView {
    func clear() {
        withAnimation {
            capturedImage = nil
            sendMode = false
        }
    }
    
    func captureImage() {
        cameraPreviewModel.capture()
    }
    
    func onImageCapture(_ image: UIImage) {
        "image captured : \(image)".ld(T)
        withAnimation {
            capturedImage = image
            sendMode = true
        }
    }
    
    func send() {
        let model = NoteModel()
        model.image = capturedImage
        myHomeViewModel.navPush(.init(viewType: .noteEdit(model: model)))
    }
}
