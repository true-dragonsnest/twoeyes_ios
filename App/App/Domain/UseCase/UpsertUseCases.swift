//
//  UpsertUseCases.swift
//  App
//
//  Created by Yongsik Kim on 1/5/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Upsert {}
}

extension UseCases.Upsert {
    /* FIXME: delete
    /// returns created `noteId`
    static func insert(note: EntityNote) async throws -> Int {
        do {
            guard let query = BackEnd.Notes.insert(note, returnInserted: true).query else {
                throw AppError.invalidRequest()
            }
            let response = try await query.execute()
            let created: [EntityNote] = try SupabaseService.shared.decoder.decode([EntityNote].self, from: response.data)
            "note created : \(o: created.jsonPrettyPrinted)".ld(T)
            guard let noteId = created.first?.id else {
                throw AppError.invalidResponse("invalid response".le(T))
            }
            return noteId
        } catch {
            "Failed to create note for \(o: note.jsonPrettyPrinted) : \(error)".le(T)
            throw error
        }
    }
    
    static func insert(cards: [EntityCard]) async throws {
        do {
            guard let query = BackEnd.Cards.insert(cards).query else {
                throw AppError.invalidRequest()
            }
            let response = try await query.execute()
            "cards created : \(response)".ld(T)
        } catch {
            "Failed to create cards : \(error)".le(T)
            throw error
        }
    }
    */
}
