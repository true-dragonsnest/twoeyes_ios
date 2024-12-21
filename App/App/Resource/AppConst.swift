//
//  AppConst.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI

// FIXME: to more secure area
enum AppKey {
    static let supabaseProjectUrl = "https://dhnlijkwrnoxbgakcxvj.supabase.co"
    static let supabaseApiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRobmxpamt3cm5veGJnYWtjeHZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ4MjY0ODEsImV4cCI6MjAzMDQwMjQ4MX0.7YSJ-bAOpypD1A9rk-gB6_7zQU0hF4qkYRX-X-q1MYI"
    
    static let s3AccessKey = "462e33547cbb9182d8dffd297d740f1e"
    static let s3SecretKey = "00e1a494db575f1952688d5784375329938d55600ab4eb5239cf1b6e8a84c8bd"
    static let s3Endpoint = "https://7dc29b549999a730704a07f96d570cbc.r2.cloudflarestorage.com"
}

enum AppConst {
    static let minUserIdLength: Int = 4
    static let maxUserIdLength: Int = 20
}
