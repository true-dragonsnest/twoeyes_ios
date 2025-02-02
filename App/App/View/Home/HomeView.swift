//
//  HomeView.swift
//  App
//
//  Created by Yongsik Kim on 1/27/25.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navPath) {
            contentView
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        "plus.circle.fill".navbarButtonApp {
                            viewModel.navPush(.init(viewType: .talk))
                        }
                    }
                }
                .navigationDestination(for: HomeViewModel.NavPath.self) { path in
                    switch path.viewType {
                    case .talk:
                        TalkView()
                            .environmentObject(viewModel)
                    }
                }
        }
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack {
                Text("home")
                //testView
            }
        }
    }
    
    /*
    @State var showingPicker = false
    @State var selectedItem: PhotosPickerItem?
    @State var player: AVPlayer?
    @State var audioPlayer: AVAudioPlayer?
    
    var testView: some View {
        Button(action: {
            showingPicker = true
        }) {
            Label("Select Video", systemImage: "video.badge.plus")
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .photosPicker(isPresented: $showingPicker, selection: $selectedItem, matching: .videos, photoLibrary: .shared())
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task {
                if let identifier = item.itemIdentifier,
                   let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject,
                   let url = try? await UseCases.AudioExtract.extract(from: asset)
                {
//                    player = AVPlayer(url: url)
//                    player?.play()
//                    do {
//                        _ = try? await UseCases.VoiceGen.cloneVoice(name: "iu_test_x", file: url)
//                    } catch {
//                        ContentViewModel.shared.error = error
//                    }
                    
                    do {
                        let voiceData = try await UseCases.VoiceGen.genVoice(
                            voiceId: "s3://voice-cloning-zero-shot/deba4db7-d3c5-4b54-843e-d6eec7e37d25/original/manifest.json",
                            text: "Hey there! I'm doing well, thanks for asking. How about you? Anything exciting happening in your world today?")
                        
                        audioPlayer = try AVAudioPlayer(data: voiceData)
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                        try AVAudioSession.sharedInstance().setActive(true)
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                    } catch {
                        "failed to generate voice : \(error)".le()
                        ContentViewModel.shared.error = error
                    }
                }
            }
        }
    }
    */
}

