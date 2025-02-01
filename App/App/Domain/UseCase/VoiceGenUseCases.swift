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
        
        
    }
}
