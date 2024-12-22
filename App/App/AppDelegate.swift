//
//  AppDelegate.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation
import FirebaseCore
import UIKit

private let T = #fileID

public class AppDelegate: NSObject, UIApplicationDelegate {
    public private(set) lazy var bundleId: String? = Bundle.main.bundlePath
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        AppLogger.shared.setFilterLevel(.debug)
        
        "APP init : \(o: bundleId)".ld(T)
        
        initApns()
        // FIXME: enable if needed, initFirebase()
        "APP init done".ld(T)
        
        return true
    }
    
    private var firebaseInited = false
    private func initFirebase() {
        if !firebaseInited {
            firebaseInited = true
            FirebaseApp.configure()
        }
    }
}

// MARK: - APNS

extension AppDelegate: UNUserNotificationCenterDelegate {
    private func initApns() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            "UNUserNotificationCenter granted? : \(granted), \(o: error)".ld(T)
            
            if !granted {
                // TODO: what?
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    public func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        "PUSH NOTIFICATION device token: \(deviceToken)".ld(T)
        PushNotificationService.shared.initService(deviceToken: deviceToken)
    }
    
    public func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        "Failed to register to renote notification : \(error)".le(T)
    }
    
    public func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        "PUSH NOTIFICATION didReceiveRemoteNotification".li(T)
        completionHandler(.noData)
    }
    
    public func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        "PUSH NOTIFICATION open url : \(url)".li(T)
        return false
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        PushNotificationService.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushNotificationService.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}

