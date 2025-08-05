import Foundation

struct EntityCommentMention: Identifiable, Codable {
    let id: String
    let commentId: String
    let mentionType: String
    let mentionedId: String
}

enum CommentMentionType: String, Codable {
    case article
    case user
    case comment
}
