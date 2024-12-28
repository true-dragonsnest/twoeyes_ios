//
//  CameraButton.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

struct CameraButton: View {
    @Binding var sendMode: Bool
    let height: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.regularMaterial)
                .frame(width: height + 16, height: height + 16)
            
            Group {
                if sendMode == false {
                    Circle()
                        .fill(Color.white.gradient.opacity(0.8))
                        .frame(width: height, height: height)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.ultraThinMaterial.opacity(0.3))
                                .frame(width: height / 2, height: height / 2)
                        }
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            onTap()
                        }
                } else {
                    Color.clear
                        .frame(width: height, height: height)
                        .overlay {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.ultraThinMaterial.opacity(0.3))
                                .frame(width: height / 2, height: height / 2)
                        }
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            onTap()
                        }
                }
            }
            .background {
                RandomGradientAnimationView(colors: [.blue, .purple, .red, .green], duration: 3)
            }
            .clipShape(.circle)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    @Previewable @State var sendMode = false
    CameraButton(sendMode: $sendMode, height: 80) {
        withAnimation {
            sendMode.toggle()
        }
    }
}

