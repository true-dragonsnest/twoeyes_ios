//
//  AppLogger.swift
//  Nest0
//
//  Created by Yongsik Kim on 2021/07/23.
//

import Foundation
import os

public class AppLogger {
    public enum LogLevel: Int {
        case debug = 0
        case info = 1
        case `default` = 2
        case error = 3
        case fault = 4

        func osLogType() -> OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .default: return .default
            case .error: return .error
            case .fault: return .fault
            }
        }

        func prefix() -> String {
            switch self {
            case .debug: return "[DN⚫️"
            case .info: return "[DN🔵"
            case .default: return "[DN🟢"
            case .error: return "[DN🟠"
            case .fault: return "[DN🔴"
            }
        }
    }

    public static let shared = AppLogger()

    private(set) var filterLevel: LogLevel?

    private init() {}

    public func setFilterLevel(_ level: LogLevel) {
        filterLevel = level
    }

    func logPrivate(_ str: String, level: LogLevel) {
        if let filterLevel = filterLevel, level.rawValue < filterLevel.rawValue {
            return
        }
        if #available(iOS 14, *) {
            Logger().log(level: level.osLogType(), "🤐\(level.prefix() + " " + str, privacy: .private)")
        } else {
            NSLog("🤐\(level.prefix() + " " + str)")
        }
    }

    func logPublic(_ str: String, level: LogLevel) {
        if let filterLevel = filterLevel, level.rawValue < filterLevel.rawValue {
            return
        }
        if #available(iOS 14, *) {
            Logger().log(level: level.osLogType(), "\(level.prefix() + " " + str)")
        } else {
            NSLog("\(level.prefix() + " " + str)")
        }
    }
}
