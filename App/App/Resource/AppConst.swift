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
}

enum AppConst {
    static let minUserIdLength: Int = 4
    static let maxUserIdLength: Int = 20
    
    static let maxImageAttachments: Int = 3
}
