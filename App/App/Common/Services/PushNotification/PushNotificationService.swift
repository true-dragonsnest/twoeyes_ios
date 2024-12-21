//
//  PushNotificationService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/12/27.
//

import Firebase
import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UserNotifications

private let T = #fileID

public extension PushNotificationService {
    enum Event: String {
        case deviceTokenChanged
        case foregroundNotificationReceived
        case remoteNotificationClicked

        private static let deviceTokenChangedPublisher = NotificationCenter.default.publisher(for: Event.deviceTokenChanged.notificationName)
        private static let foregroundNotificationReceivedPublisher = NotificationCenter.default.publisher(for: Event.foregroundNotificationReceived.notificationName)
        private static let remoteNotificationClickedPublisher = NotificationCenter.default.publisher(for: Event.remoteNotificationClicked.notificationName)

        public var notificationName: Notification.Name {
            Notification.Name(rawValue)
        }

        public var publisher: NotificationCenter.Publisher {
            switch self {
            case .deviceTokenChanged:
                return Event.deviceTokenChangedPublisher
            case .foregroundNotificationReceived:
                return Event.foregroundNotificationReceivedPublisher
            case .remoteNotificationClicked:
                return Event.remoteNotificationClickedPublisher
            }
        }
    }
}

public class PushNotificationService: NSObject {
    public static let shared = PushNotificationService()
    private var inited = false

    public private(set) var apnsToken: Data?
    public private(set) var fcmToken: String?

    override private init() {
        super.init()
    }

    public func initService(deviceToken: Data) {
        guard !inited else { return }

        inited = true

        initFirebaseFCM(deviceToken: deviceToken)
    }

    public func subscribe(toTopic topic: String) {
        "Subscribing to \(topic)".ld(T)
        Messaging.messaging().subscribe(toTopic: topic)
    }

    public func unsubscribe(fromTopic topic: String) {
        "Unsubscribing from \(topic)".ld(T)
        Messaging.messaging().unsubscribe(fromTopic: topic)
    }
}

extension PushNotificationService: MessagingDelegate {
    private func initFirebaseFCM(deviceToken: Data) {
        guard let _ = FirebaseApp.app() else {
            "Firebase not inited".lf(T)
            return
        }

        apnsToken = deviceToken
        Messaging.messaging().delegate = self
        Messaging.messaging().apnsToken = deviceToken
    }

    public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let fcmToken = fcmToken ?? ""
        "FCM token : \(fcmToken)".ld(T)
        self.fcmToken = fcmToken
        NotificationCenter.default.post(name: Event.deviceTokenChanged.notificationName, object: fcmToken)
    }
}

// MARK: - APNS delegate mirror

public extension PushNotificationService {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        "PUSH NOTIFICATION (foreground): \(userInfo)".ld(T)

        completionHandler([.badge, .sound]) // FIXME: from app settings

        if let pushEntity = parsePushNotificationPayload(userInfo: userInfo) {
            NotificationCenter.default.post(name: Event.foregroundNotificationReceived.notificationName, object: pushEntity)
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        "PUSH NOTIFICATION CLICKED: \(userInfo)".ld(T)

        completionHandler()

        if let pushEntity = parsePushNotificationPayload(userInfo: userInfo) {
            NotificationCenter.default.post(name: Event.remoteNotificationClicked.notificationName, object: pushEntity)
        }
    }

    private func parsePushNotificationPayload(userInfo: [AnyHashable: Any]) -> EntityPushNotification? {
        do {
            guard let userInfoDic = userInfo as? [String: Any] else {
                "invalid push payload: \(userInfo)".le(T)
                return nil
            }
            let pushEntity: EntityPushNotification = try EntityPushNotification.decode(fromJsonDic: userInfoDic)
            return pushEntity
        } catch {
            "Failed to parse push payload: \(error)".le(T)
        }
        return nil
    }
}
