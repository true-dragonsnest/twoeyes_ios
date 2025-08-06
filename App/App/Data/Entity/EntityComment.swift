import Foundation

struct EntityComment: Identifiable, Codable {
    let id: String
    let threadId: Int
    let userId: String
    let content: String
    let userSentiment: Double?
    let aiSentiment: Double?
    let aiSentimentConfidence: Double?
    let isAiGenerated: Bool
    let createdAt: Date
    let updatedAt: Date?
    let mentions: [EntityCommentMention]?
}