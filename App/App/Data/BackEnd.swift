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
    
    enum Notes {
        static let table = "notes"
        static var rootQueryBuilder: PostgrestQueryBuilder? {
            SupabaseService.shared.client?.from(Self.table)
        }
        
        case list(_ userId: UUID)   // FIXME: pagination
        case fetch(_ noteId: Int)
        case insert(_ note: EntityNote, returnInserted: Bool)
        
        var query: PostgrestBuilder? {
            switch self {
            case let .list(userId):
                return Self.rootQueryBuilder?.select().eq("userId", value: userId)
            case let .fetch(noteId):
                return Self.rootQueryBuilder?.select().eq("id", value: noteId)
            case let .insert(note, returnInserted):
                do {
                    return try Self.rootQueryBuilder?.insert(note, returning: returnInserted ? .representation : nil)
                } catch {
                    "Notes.insert failed for \(o: note.jsonPrettyPrinted) : \(error)".le(T)
                    return nil
                }
            }
        }
    }
    
    enum Cards {
        static let table = "cards"
        static var rootQueryBuilder: PostgrestQueryBuilder? {
            SupabaseService.shared.client?.from(Self.table)
        }
        
        case fetch(noteId: Int)
        case insert(_ cards: [EntityCard])
        
        var query: PostgrestBuilder? {
            switch self {
            case let .fetch(noteId):
                return Self.rootQueryBuilder?.select().eq("noteId", value: noteId)
            case let .insert(cards):
                do {
                    return try Self.rootQueryBuilder?.insert(cards)
                } catch {
                    "Cards.insert failed : \(error)".le(T)
                    return nil
                }
            }
        }
    }
    
    enum Storage {
        case data
        
        var bucket: String {
            switch self {
            case .data: return "talk-data"
            }
        }
        
        var endpoint: String {
            switch self {
            case .data: return
                "https://pub-617f65a224a8486fbda149467b24a700.r2.dev"
            }
        }
        
        static func imageContentType(from path: String) -> String {
            let ext = URL(fileURLWithPath: path).pathExtension
            return "image/\(ext.lowercased())"
        }
    }
}

