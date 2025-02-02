//
//  TalkModel.swift
//  App
//
//  Created by Yongsik Kim on 1/28/25.
//

import SwiftUI
import AVFoundation

private let T = #fileID

@Observable
class TalkModel {
    let talkId: String = "test"
    let voiceId: String? = "s3://voice-cloning-zero-shot/deba4db7-d3c5-4b54-843e-d6eec7e37d25/original/manifest.json"
    
    var chats: [EntityChat] = []
    var voiceGenInProgress: [UUID: Bool] = [:]
    var voicePlayChat: EntityChat?
    
    var chatSuggestions: [String] = []
    
    private(set) var player: AVPlayer?
    private(set) var audioPlayer: AVAudioPlayer?
    
    @MainActor
    func playChat(_ chat: EntityChat) async {
        guard let voiceId else {
            "no voice ID".le(T)
            return
        }
        
        if let voiceUrl = URL(fromString: chat.voiceUrl) {
            voicePlayChat = chat

            player = AVPlayer(url: voiceUrl)
            player?.play()
        } else {
            if voiceGenInProgress[chat.id] == true {
                "voice gen in progress : \(chat.message)".ld(T)
                return
            }
            
            voiceGenInProgress[chat.id] = true
            
            do {
                defer { voiceGenInProgress[chat.id] = false }
                let voiceData = try await UseCases.VoiceGen.genVoice(voiceId: voiceId, text: chat.message)
                Task {
                    await uploadVoice(chat: chat, voiceData: voiceData)
                }
                audioPlayer = try AVAudioPlayer(data: voiceData)
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                "failed to generate voice : \(error)".le()
                ContentViewModel.shared.error = error
                return
            }
        }
    }
    
    private func uploadVoice(chat: EntityChat, voiceData: Data) async {
        let filepath = "talks/" + talkId + "/" + chat.id.uuidString + ".mp3"
        let uploadUrl = BackEnd.Storage.data.endpoint + "/" + filepath
        
        "voice uploading to \(uploadUrl)".ld()
        do {
            try await S3StorageService.shared.upload(
                voiceData,
                bucket: BackEnd.Storage.data.bucket,
                filePath: filepath,
                contentType: "audio/mpeg")
        } catch {
            "failed to upload voice to \(uploadUrl) : \(error)".le(T)
        }
        
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            var update = chat
            update.voiceUrl = uploadUrl
            let u = update
            await MainActor.run {
                chats[index] = u
            }
        }
        "voice upload done".ld()
    }
}
