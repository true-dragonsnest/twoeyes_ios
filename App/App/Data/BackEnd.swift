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
                return Self.rootQueryBuilder?.select().order("updated_at", ascending: false)
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
    
    enum Articles {
        static let table = "articles"
        static var rootQueryBuilder: PostgrestQueryBuilder? {
            SupabaseService.shared.client?.from(Self.table)
        }
        
        case fetchList(start: Int?, limit: Int)
        
        var query: PostgrestBuilder? {
            switch self {
            case let .fetchList(start, limit):
                var ret = Self.rootQueryBuilder?.select()
                if let start {
                    ret = ret?.lt("id", value: start)
                }
                return ret?.order("id", ascending: false).limit(limit)
            }
        }
    }
    
    enum Threads {
        static let table = "threads"
        static var rootQueryBuilder: PostgrestQueryBuilder? {
            SupabaseService.shared.client?.from(Self.table)
        }
        
        case fetchList(start: Int?, limit: Int)
        case fetch(threadId: Int)
        
        var query: PostgrestBuilder? {
            switch self {
            case let .fetchList(start, limit):
                var ret = Self.rootQueryBuilder?.select()
                if let start {
                    ret = ret?.lt("id", value: start)
                }
                return ret?.order("id", ascending: false).limit(limit)
            case let .fetch(threadId):
                let ret = Self.rootQueryBuilder?.select()
                            .eq("id", value: threadId)
                return ret
            }
        }
    }
    
    enum Functions {
        static let endpoint = "https://bgnymsxduwfrauidowxx.supabase.co/functions/v1"
        static func decoder() -> JSONDecoder {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategyFormatters = SupabaseService.dateFormatters
            return decoder
        }
        
        static func encoder() -> JSONEncoder {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(SupabaseService.dateFormatters[0])
            return encoder
        }
        
        case addArticle
        case findSimilarThreads
        case addArticleToThread
        case addComment
        case getThreadComments
        case updateComment
        case deleteComment
        
        var url: String {
            switch self {
            case .addArticle: Self.endpoint + "/add-article"
            case .findSimilarThreads: Self.endpoint + "/find-similar-threads"
            case .addArticleToThread: Self.endpoint + "/add-article-to-thread"
            case .addComment: Self.endpoint + "/add-comment"
            case .getThreadComments: Self.endpoint + "/get-thread-comments"
            case .updateComment: Self.endpoint + "/update-comment"
            case .deleteComment: Self.endpoint + "/delete-comment"
            }
        }
    }
    
    /* FIXME: delete
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
    */
    
    enum Storage {
        case userData
        
        var bucket: String {
            switch self {
            case .userData: return "user-data"
            }
        }
        
        var endpoint: String {
            switch self {
            case .userData: return
                "https://pub-e4545979b43b4c29bab599ad249c9b8f.r2.dev"
            }
        }
        
        static func imageContentType(from path: String) -> String {
            let ext = URL(fileURLWithPath: path).pathExtension
            return "image/\(ext.lowercased())"
        }
    }
}

