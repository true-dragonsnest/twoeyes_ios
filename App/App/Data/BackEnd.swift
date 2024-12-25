//
//  BackEnd.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation
import Supabase

private let T = #fileID

enum BackEnd {
    enum Intro {
        static let table = "intro"
        static var rootQueryBuilder: PostgrestQueryBuilder? {
            SupabaseService.shared.client?.from(Self.table)
        }
        case fetch
        
        var query: PostgrestBuilder? {
            switch self {
            case .fetch:
                return Self.rootQueryBuilder?.select().order("updatedAt", ascending: false)
            }
        }
    }
    
    enum Users {
        static let table = "users"
        static var rootQueryBuilder: PostgrestQueryBuilder? {
            SupabaseService.shared.client?.from(Self.table)
        }
        
        case fetch(_ userId: UUID)
        case insert(_ user: EntityUser)
        
        var query: PostgrestBuilder? {
            switch self {
            case let .fetch(userId):
                return Self.rootQueryBuilder?.select().eq("id", value: userId)
            case let .insert(user):
                do {
                    return try Self.rootQueryBuilder?.insert(user)
                } catch {
                    "Users.insert failed for \(o: user.jsonPrettyPrinted) : \(error)".le(T)
                    return nil
                }
            }
        }
    }
    
    enum Storage {
        case common
        
        var bucket: String {
            switch self {
            case .common: return "selfquize-common"
            }
        }
        
        var endpoint: String {
            switch self {
            case .common: return "https://pub-a98cd200a2cb44b5bcc7d5f633ff46ef.r2.dev"
            }
        }
        
        static func imageContentType(from path: String) -> String {
            let ext = URL(fileURLWithPath: path).pathExtension
            return "image/\(ext.lowercased())"
        }
    }
}

