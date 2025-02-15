//
//  AppConst.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI

enum AppEnvironment {
    enum Supabase {
        static let projectUrl = UseCases.ReadPlist.execute(fileName: "Environment", key: "supabaseProjectUrl")
        static let apiKey = UseCases.ReadPlist.execute(fileName: "Environment", key: "supabaseApiKey")
    }
    
    enum S3 {
        static let accessKey = UseCases.ReadPlist.execute(fileName: "Environment", key: "s3AccessKey")
        static let secretKey = UseCases.ReadPlist.execute(fileName: "Environment", key: "s3SecretKey")
        static let endpoint = UseCases.ReadPlist.execute(fileName: "Environment", key: "s3Endpoint")
    }
    
    enum Gemini {
        static let apiKey: String = UseCases.ReadPlist.execute(fileName: "Environment", key: "geminiApiKey")
    }
    
    enum Gpt {
        static let authKey: String = UseCases.ReadPlist.execute(fileName: "Environment", key: "gptAuthKey")
    }
    
    enum ElevenLabs {
        static let apiKey: String = UseCases.ReadPlist.execute(fileName: "Environment", key: "elevenLabsApiKey")
    }
    
    enum PlayHt {
        static let userId: String = UseCases.ReadPlist.execute(fileName: "Environment", key: "playHtUserId")
        static let apiKey: String = UseCases.ReadPlist.execute(fileName: "Environment", key: "playHtApiKey")
    }
}

enum AppConst {
    static let minUserIdLength: Int = 4
    static let maxUserIdLength: Int = 20
}
