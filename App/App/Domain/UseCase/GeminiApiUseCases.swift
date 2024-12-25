//
//  GeminiApiUseCases.swift
//  App
//
//  Created by Yongsik Kim on 12/24/24.
//

import SwiftUI
import GoogleGenerativeAI

private let T = #fileID

extension UseCases {
    enum GeminiApi {
        static let defaultConfig: GenerationConfig = .init(
            temperature: 1,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 8192,
            responseMIMEType: "text/plain"
        )
        static let model = "gemini-1.5-flash"
        
        static func generate(with image: UIImage, prompt: String, config: GenerationConfig = defaultConfig) async throws {
            let genModel = GenerativeModel(name: model,
                                           apiKey: AppKey.geminiApiKey,
                                           generationConfig: config,
                                           systemInstruction: prompt)
            let response = try await genModel.generateContent(image)
            "Response : \(response)".ld(T)
        }
    }
}

/*
 // NOTE: Your prompt contains media inputs, which are not currently supported by
 // the Swift SDK. The code snippet below may be incomplete.
 //
 // See here for more information and updates:
 // https://ai.google.dev/gemini-api/docs/prompting_with_media

 

 let config = GenerationConfig(
   temperature: 1,
   topP: 0.95,
   topK: 40,
   maxOutputTokens: 8192,
   responseMIMEType: "text/plain"
 )

 // Don't check your API key into source control!
 guard let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] else {
   fatalError("Add GEMINI_API_KEY as an Environment Variable in your app's scheme.")
 }

 let model = GenerativeModel(
   name: "gemini-1.5-flash",
   apiKey: apiKey,
   generationConfig: config,
   systemInstruction: "주어진 이미지는 공부 노트야.    \n노트의 내용을 확인할 수 있도록, 노트의 내용에만 한정해서 객관식 문제를 10개 만들어줘.    \n객 객관식 문제에는 3개의 선택지가 있고, 1개의 선택지만 정답이야.  \n\n출력은 다음 형식으로.\nQuestionItem = {'question': string, 'answers': [string], 'correctAnswer': int}\nReturn: Array<QuestionItem>\n"
 )

 let chat = model.startChat(history: [
   ModelContent(
     role: "model",
     parts: [
       .text("```json\n[\n  {\n    \"question\": \"말의 뜻을 구별하는 소리의 가장 작은 단위는 무엇인가?\",\n    \"answers\": [\"음절\", \"음운\", \"단어\"],\n    \"correctAnswer\": 1\n  },\n  {\n    \"question\": \"어떤 말의 발음이 조건에 따라 달라지는 현상을 무엇이라고 하는가?\",\n    \"answers\": [\"음운 동화\", \"음운 변동\", \"음절 변동\"],\n    \"correctAnswer\": 1\n  },\n  {\n    \"question\": \"음절의 끝소리 규칙에 해당하는 자음은 무엇인가?\",\n    \"answers\": [\"ㄱ, ㄴ, ㄷ, ㄹ, ㅁ, ㅂ, ㅇ\", \"ㄱ, ㅋ, ㄲ, ㅅ, ㅆ\", \"ㅈ, ㅊ, ㅎ\"],\n    \"correctAnswer\": 0\n  },\n  {\n    \"question\": \"음절의 끝소리 규칙에서, 빛[빛]의 '빛'은 어떻게 발음되는가?\",\n    \"answers\": [\"[빛]\", \"[빅]\", \"[빗]\"],\n    \"correctAnswer\": 0\n  },\n  {\n    \"question\": \"음운 동화 중 비음화에 해당하는 것은 무엇인가?\",\n    \"answers\": [\"'ㄱ, ㄷ, ㅂ'이 'ㄴ, ㅁ'과 만나 'ㄴ, ㅁ'으로 변하는 현상\", \"'ㄷ, ㅌ'이 'ㅣ'와 만나 'ㅈ, ㅊ'으로 변하는 현상\", \"'ㄹ'이 'ㄹ'과 만나 'ㄹ'로 변하는 현상\"],\n    \"correctAnswer\": 0\n  },\n  {\n    \"question\": \"비음화의 예시로 적절한 것은?\",\n    \"answers\": [\"닫는[단는]\", \"칼날[칼랄]\", \"같이[가치]\"],\n    \"correctAnswer\": 0\n  },\n  {\n    \"question\": \"유음화의 예시로 적절한 것은?\",\n    \"answers\": [\"닫는[단는]\", \"칼날[칼랄]\", \"같이[가치]\"],\n    \"correctAnswer\": 1\n  },\n  {\n    \"question\": \"구개음화의 예시로 적절한 것은?\",\n    \"answers\": [\"닫는[단는]\", \"칼날[칼랄]\", \"같이[가치]\"],\n    \"correctAnswer\": 2\n  },\n  {\n    \"question\": \"'ㄱ, ㄷ, ㅂ' + 'ㄴ, ㅁ, ㅇ' 의 비음화 결과는 무엇인가?\",\n    \"answers\": [\"ㄴ, ㅁ\", \"ㅇ\", \"ㄱ, ㄷ, ㅂ\"],\n    \"correctAnswer\": 1\n  },\n  {\n    \"question\": \"'ㄷ, ㅌ' + 'ㅣ' 의 구개음화 결과는 무엇인가?\",\n    \"answers\": [\"ㄷ, ㅌ\", \"ㅈ, ㅊ\", \"ㄱ, ㅋ\"],\n    \"correctAnswer\": 1\n  }\n]\n```")
     ]
   )
 ])

 Task {
   do {
     let message = "INSERT_INPUT_HERE"
     let response = try await chat.sendMessage(message)
     print(response.text ?? "No response received")
   } catch {
     print(error)
   }
 }
 */
