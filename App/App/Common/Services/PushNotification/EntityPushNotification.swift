//
//  EntityPushNotification.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/12/27.
//

import Foundation

public struct EntityPushNotification: Codable {
    public var aps: EntityPushNotificationAps?
    public var fcmOptions: EntityPushNotificationFcmOptions?

    enum CodingKeys: String, CodingKey {
        case aps
        case fcmOptions = "fcm_options"
    }
}

public struct EntityPushNotificationAps: Codable {
    public var alert: EntityPushNotificationApsAlert?
    public var mutableContent: Int?

    enum CodingKeys: String, CodingKey {
        case alert
        case mutableContent = "mutable-content"
    }
}

public struct EntityPushNotificationApsAlert: Codable {
    public var body: String?
    public var title: String?
}

public struct EntityPushNotificationFcmOptions: Codable {
    public var image: String?
}
