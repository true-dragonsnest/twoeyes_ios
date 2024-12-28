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
    
    @StateObject var cameraPreviewModel = ZoomCameraPreviewModel(aspectRatio: 9 / 16)
    @State var capturedImage: UIImage?
    @State var sendMode = false
    
    @State var inProgress = false
    
    var body: some View {
        contentView
            .navigationTitle("Add Note")
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

    }
    
    var contentView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                preview
                    .padding(.vertical)
                Spacer()
                controls
                    .padding(.bottom)
            }
            
            if inProgress {
                ModalProgressView()
                    .ignoresSafeArea()
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
                            .foregroundStyle(.label3)
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
            CameraButton(sendMode: $sendMode, height: 80) {
                if sendMode == false {
                    captureImage()
                } else {
                    send()
                }
            }
            Spacer()
            trailingButtons
            Spacer()
        }
    }
    
    var leadingButtons: some View {
        Color(uiColor: .systemBackground)
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
        Color(uiColor: .systemBackground)
            .overlay {
            }
            .frame(width: 60, height: 60)
            .clipped()
    }
    
    var cancelButton: some View {
        Image(systemName: "xmark")
            .font(.title)
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                clear()
            }
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
