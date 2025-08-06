//
//  IntroUseCases.swift
//  App
//
//  Created by Yongsik Kim on 8/6/25.
//

import Foundation

private let T = #fileID

extension UseCases {
    enum Intro {
        static func fetch() async throws -> EntityIntro {
            let intros: [EntityIntro]
            do {
                intros = try await SupabaseService.shared.fetch(from: BackEnd.Intro.fetch.query)
            } catch {
                "failed to read intro : \(error)".le(T)
                throw error
            }
            guard let intro = intros.first else {
                "no intro fetched".lf(T)
                throw AppError.notFound()
            }
            return intro
        }
    }
}