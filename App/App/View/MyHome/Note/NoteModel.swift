//
//  NoteModel.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

@Observable
class NoteModel {
    var image: UIImage?
    var title: String = ""
    var tags: [String] = []
    var isPrivate = false
    
    var cards: [EntityCard] = []
    
    var isEditMode = false
    
    init() {
    }
    
    convenience init(from entity: EntityNote) {
        self.init()
        // FIXME: code here
    }
    
    func generate() async throws {
        guard let userId = LoginUserModel.shared.user?.id else { return }
        guard let image else { return }
        
        let systemPrompt =
"""
The given image is a list of foreign language words.

Extract each word and its meaning while preserving the original text and language in the image.
Then, create three incorrect definitions for each meaning.

- question: foreign language word in English
- answer, incorrect answers : word meaning in Korean

Also, generate based on the additional commands entered by the user.

Write your response in JSON format, not markdown style in this format:
[
    {
        'question': String,
        'answer': String,
        'incorrectAnsweers': [String]
    }
]

"""

        let userPrompt =
"""
"""
        
        struct Response: Codable {
            var question: String
            var answer: String
            var incorrectAnswers: [String]
        }
        
        do {
            let response = try await UseCases.GeminiApi.generate(with: image,
                                                                 systemPrompt: systemPrompt,
                                                                 userPrompt: userPrompt,
                                                                 responseMIMEType: "application/json",
                                                                 temperature: 0.1)
            guard let parsed: [Response] = try [Response].decode(fromJsonStr: response.text) else {
                ContentViewModel.shared.error = AppError.invalidResponse("invalid AI response: \(response)".le())
                return
            }
            
//            let text = "[{\"question\": \"receive\", \"answer\": \"받다\", \"incorrectAnswers\": [\"주다\", \"보내다\", \"던지다\"]}, {\"question\": \"different\", \"answer\": \"다른\", \"incorrectAnswers\": [\"같은\", \"비슷한\", \"유사한\"]}, {\"question\": \"enough\", \"answer\": \"충분한\", \"incorrectAnswers\": [\"부족한\", \"적은\", \"모자란\"]}, {\"question\": \"worry\", \"answer\": \"걱정하다\", \"incorrectAnswers\": [\"행복해하다\", \"즐거워하다\", \"기뻐하다\"]}, {\"question\": \"little\", \"answer\": \"조금\", \"incorrectAnswers\": [\"많이\", \"대단히\", \"엄청나게\"]}, {\"question\": \"my\", \"answer\": \"나의\", \"incorrectAnswers\": [\"너의\", \"그의\", \"우리의\"]}, {\"question\": \"spend\", \"answer\": \"쓰다\", \"incorrectAnswers\": [\"벌다\", \"모으다\", \"절약하다\"]}, {\"question\": \"rest\", \"answer\": \"쉬다\", \"incorrectAnswers\": [\"일하다\", \"움직이다\", \"활동하다\"]}, {\"question\": \"climb\", \"answer\": \"오르다\", \"incorrectAnswers\": [\"내리다\", \"떨어지다\", \"앉다\"]}]"
//            guard let parsed: [Response] = try [Response].decode(fromJsonStr: text) else {
//                throw AppError.invalidResponse("invalid AI response: \(text)".le())
//            }
            
            "generated : \(o: parsed.jsonPrettyPrinted)".li()
            
            await MainActor.run {
                cards = parsed.map { item in
                    EntityCard(createdAt: .now,
                               updatedAt: .now,
                               userId: userId,
                               noteId: 0,
                               question: item.question,
                               answer: item.answer,
                               incorrectAnswers: item.incorrectAnswers,
                               sttEnabled: true,
                               isPrivate: false)
                }
            }
        } catch {
            "failed to generate : \(error)".le()
            throw error
        }
    }
}
