//
//  AppConst.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI

enum AppKey {
    static let supabaseProjectUrl = UseCases.ReadPlist.execute(fileName: "Keys", key: "supabaseProjectUrl")
    static let supabaseApiKey = UseCases.ReadPlist.execute(fileName: "Keys", key: "supabaseApiKey")
    
    static let s3AccessKey = UseCases.ReadPlist.execute(fileName: "Keys", key: "s3AccessKey")
    static let s3SecretKey = UseCases.ReadPlist.execute(fileName: "Keys", key: "s3SecretKey")
    static let s3Endpoint = UseCases.ReadPlist.execute(fileName: "Keys", key: "s3Endpoint")
    
    static let geminiApiKey: String = UseCases.ReadPlist.execute(fileName: "Keys", key: "GeminiApiKey")
}

enum AppConst {
    static let minUserIdLength: Int = 4
    static let maxUserIdLength: Int = 20
}
