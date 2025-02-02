//
//  VoiceGenUseCases.swift
//  App
//
//  Created by Yongsik Kim on 2/1/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum VoiceGen {
        static func cloneVoice(name: String, file: URL) async throws -> String {
            guard let url = URL(string: "https://api.play.ht/api/v2/cloned-voices/instant") else {
                fatalError()
            }
            
            let boundary = UUID().uuidString
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue(AppKey.playHtUserId, forHTTPHeaderField: "X-USER-ID")
            request.setValue(AppKey.playHtApiKey, forHTTPHeaderField: "AUTHORIZATION")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var data = Data()
            
            let params = [
                "voice_name": name,
            ]
            for (key, value) in params {
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            func multipartData() throws -> Data {
                guard let fileData = try? Data(contentsOf: file) else {
                    throw AppError.invalidRequest("invalid file".le(T))
                }
                "filedata : \(fileData)".ld(T)
                let fileName = file.lastPathComponent
                var data = Data()
                
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
// FIXME: not working... why?
//                data.append("Content-Disposition: form-data; name=\"sample_file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
//                data.append("Content-Type: audio/mp4\r\n\r\n".data(using: .utf8)!)
//                data.append(fileData)
                data.append("Content-Disposition: form-data; name=\"sample_file_url\"\r\n\r\n".data(using: .utf8)!)
                data.append("https://pub-a98cd200a2cb44b5bcc7d5f633ff46ef.r2.dev/ScreenRecording_01-28-2025%2021-41-17_1.mp3\r\n".data(using: .utf8)!)
                return data
            }
            
            data.append(try multipartData())
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            
            request.httpBody = data
            
            let (voiceData, response) = try await URLSession.shared.data(for: request)
            
            let code = (response as? HTTPURLResponse)?.statusCode
            let json: [String?: Any]?
            do {
                json = try JSONSerialization.jsonObject(with: voiceData, options: []) as? [String?: Any]
            } catch {
                throw AppError.invalidResponse("invalid json response : \(voiceData)".le(T))
            }
            "add voice response : code = \(o: code), \(o: json)".ld(T)
            
            if code == 403 {
                // FIXME: code here, reached max number of cloned voice
            }
            
            guard code == 200, let voiceId = json?["id"] as? String else {
                throw AppError.invalidResponse("failed to add voice : \(response)".le(T))
            }
            
            "voice ID = \(voiceId)".li(T)
            return voiceId
        }
        
        static func genVoice(voiceId: String, text: String) async throws -> Data {
            struct Request: Codable {
                let text: String
                let voice: String
                
                let quality: Quality?
                let speed: Double?  // 0 to 5.0
                
                let temperature: Double?    // 0 to 2.0
                let voiceEngine: VoiceEngine?
                let emotion: Emotion?
                let language: Language?
                
                enum Quality: String, Codable {
                    case draft
                    case low
                    case medium
                    case high
                    case premium
                }
                
                enum VoiceEngine: String, Codable {
                    case play3Mini = "Play3.0-mini"
                    case playDialog = "PlayDialog"
                    case playHT2Turbo = "PlayHT2.0-turbo"
                    case playHT2 = "PlayHT2.0"
                    case playHT1 = "PlayHT1.0"
                }
                
                enum Emotion: String, Codable {
                    case femaleHappy
                    case femaleSad
                    case femaleAngry
                    case femaleFearful
                    case femaleDisgust
                    case femaleSurprised
                    case maleHappy
                    case maleSad
                    case maleAngry
                    case maleFearful
                    case maleDisgust
                    case maleSurprised
                }
                
                enum Language: String, Codable {
                    case afrikaans
                    case albanian
                    case amharic
                    case arabic
                    case bengali
                    case bulgarian
                    case catalan
                    case croatian
                    case czech
                    case danish
                    case dutch
                    case english
                    case french
                    case galician
                    case german
                    case greek
                    case hebrew
                    case hindi
                    case hungarian
                    case indonesian
                    case italian
                    case japanese
                    case korean
                    case malay
                    case mandarin
                    case polish
                    case portuguese
                    case russian
                    case serbian
                    case spanish
                    case swedish
                    case tagalog
                    case thai
                    case turkish
                    case ukrainian
                    case urdu
                    case xhosa
                }
            }
            
            let request = Request(text: text, voice: voiceId,
                                  quality: nil, speed: nil, temperature: nil,
                                  voiceEngine: .playDialog,
                                  emotion: nil, language: nil)
            
            let http = HttpApiService()
            await http.setCommomHeader(forKey: "X-USER-ID", value: AppKey.playHtUserId)
            await http.setCommomHeader(forKey: "AUTHORIZATION", value: AppKey.playHtApiKey)
            
            do {
                let data: Data = try await http.post(request, to: "https://api.play.ht/api/v2/tts/stream", logLevel: 2)
                return data
            } catch {
                "failed to generate voice : \(error)".le(T)
                throw error
            }
        }
    }
}
