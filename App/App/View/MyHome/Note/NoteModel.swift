//
//  NoteModel.swift
//  App
//
//  Created by Yongsik Kim on 12/28/24.
//

import SwiftUI

@Observable
class NoteModel {
    var id: Int?
    var image: UIImage?
    var title: String = ""
    var noteType: EntityNote.NoteType = .vocabulary
    var tags: [String] = []
    var userPrompt: String = ""
    var isPrivate = false
    
    var cards: [EntityCard] = []
    
    var isEditMode = false
    
    init() {
    }
    
    convenience init(from entity: EntityNote) {
        self.init()
        
        id = entity.id
        title = entity.title ?? ""
        noteType = entity.noteType
        tags = entity.tags ?? []
        isPrivate = entity.isPrivate

        if let imageUrl = entity.pictureUrl {
            Task { @MainActor in
                do {
                    let image = try await UseCases.Download.image(from: imageUrl)
                    self.image = image
                } catch {
                    ContentViewModel.shared.error = error
                }
            }
        }
        
        if let noteId = id {
            Task { @MainActor in
                do {
                    let cards = try await UseCases.Fetch.noteCards(noteId: noteId)
                    self.cards = cards
                } catch {
                    ContentViewModel.shared.error = error
                }
            }
        }
    }
    
    func generate() async throws {
        guard let userId = LoginUserModel.shared.user?.id else { return }
        guard let image else { return }
        //guard let image = UIImage(named: "a") else { return }
        guard let basePrompt = basePrompts[noteType] else { return }
        
        struct Response: Codable {
            var question: String
            var answer: String
            struct Example: Codable {
                var sentence: String
                var translation: String
            }
            var examples: [Example]
        }
        
        do {
            var systemPrompt = basePrompt
            if noteType == .custom {
                systemPrompt = String(format: basePrompt, userPrompt)
            }
            
            let response = try await UseCases.GeminiApi.generate(with: image,
                                                                 systemPrompt: systemPrompt,
                                                                 userPrompt: "",
                                                                 responseMIMEType: "application/json",
                                                                 temperature: 0.1)
            let text = response.text
/*
 let text = "[{\"question\": \"receive\", \"answer\": \"받다\", \"incorrectAnswers\": [\"주다\", \"보내다\", \"던지다\"]}, {\"question\": \"different\", \"answer\": \"다른\", \"incorrectAnswers\": [\"같은\", \"비슷한\", \"유사한\"]}, {\"question\": \"enough\", \"answer\": \"충분한\", \"incorrectAnswers\": [\"부족한\", \"적은\", \"모자란\"]}, {\"question\": \"worry\", \"answer\": \"걱정하다\", \"incorrectAnswers\": [\"행복해하다\", \"즐거워하다\", \"기뻐하다\"]}, {\"question\": \"little\", \"answer\": \"조금\", \"incorrectAnswers\": [\"많이\", \"대단히\", \"엄청나게\"]}, {\"question\": \"my\", \"answer\": \"나의\", \"incorrectAnswers\": [\"너의\", \"그의\", \"우리의\"]}, {\"question\": \"spend\", \"answer\": \"쓰다\", \"incorrectAnswers\": [\"벌다\", \"모으다\", \"절약하다\"]}, {\"question\": \"rest\", \"answer\": \"쉬다\", \"incorrectAnswers\": [\"일하다\", \"움직이다\", \"활동하다\"]}, {\"question\": \"climb\", \"answer\": \"오르다\", \"incorrectAnswers\": [\"내리다\", \"떨어지다\", \"앉다\"]}]"
 */
            try await MainActor.run {
                switch noteType {
                case .vocabulary:
                    cards = try UseCases.ParseGenResult.WordCard.parse(userId: userId, response: text)
                case .custom:
                    cards = try UseCases.ParseGenResult.CustomCard.parse(userId: userId, response: text)
                }
            }
        } catch {
            "failed to generate : \(error)".le()
            throw error
        }
    }
    
    func commit() async throws {
        guard let userId = LoginUserModel.shared.user?.id else { return }
        
        guard let image,
              let encodedImage = UseCases.ImageEncode.encode(image, name: UUID().uuidString) else
        {
            throw AppError.invalidRequest("invalid note image".le())
        }
        let filepath = "notes/" + userId.uuidString + "/" + encodedImage.filename
        let imageUrl = BackEnd.Storage.data.endpoint + "/" + filepath
        
        "image uploading to \(imageUrl)".ld()
        try await S3StorageService.shared.upload(
            encodedImage.data,
            bucket: BackEnd.Storage.data.bucket,
            filePath: filepath,
            contentType: encodedImage.mime)
        "image upload done".ld()
        
        let note = EntityNote(id: id,
                              createdAt: .now,
                              updatedAt: .now,
                              userId: userId,
                              noteType: noteType,
                              title: title,
                              pictureUrl: imageUrl,
                              tags: tags,
                              isPrivate: isPrivate)
        "creating note : \(o: note.jsonPrettyPrinted)".ld()
        let noteId = try await UseCases.Upsert.insert(note: note)
        
        let cards = self.cards.map {
            var update = $0
            update.noteId = noteId
            return update
        }
        
        "creating cards : \(o: cards.jsonPrettyPrinted)".ld()
        try await UseCases.Upsert.insert(cards: cards)
    }
}

// MARK: - system prompts
private let basePrompts: [EntityNote.NoteType: String] = [
    .vocabulary: wordCardPrompt,
    .custom: customPrompt
]

private let wordCardPrompt: String =
"""
The given image is a notebook note. 
Convert it into text, focusing on the original structure and keywords.
When converting to text, keep the original language intact and there is no need to translate it into English.

Let the converted text "convertedText".

Then, create a list of questions and answers in the given image based on this command.

COMMAND:
- let each English word be a question
- let Korean meaning for the English word be answers
- for the problem/answers pair, if example sentences exist, collect the example sentence.
   if no example sentences, create three example sentences using each word along with their translations.

Finally, Write your response in JSON format, not markdown style in this format:
{
  'convertedText' : string,
  'questions' : [
      {
        'question': String,
        'answer': String,
        'examples': [ { 'sentence': String, 'translation': String } ]
      }
  ]
}
"""


private let customPrompt: String =
"""
The given image is a notebook note. 
Convert it into text, focusing on the original structure and keywords.
When converting to text, keep the original language intact and there is no need to translate it into English.

Let the converted text "convertedText".

Then, create a list of questions and answers in the given image based on this command.

COMMAND:
%@

Finally, Write your response in JSON format, not markdown style in this format:
{
  'convertedText' : string,
  'questions' : [
      {
        'question': String,
        'answer': String,
      }
  ]
}
"""
