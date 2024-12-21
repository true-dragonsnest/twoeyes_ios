//
//  Date+.swift
//  Nest1
//
//  Created by Yongsik Kim on 2021/12/21.
//

import Foundation

public extension Date {
    enum DNDateTimeFormat {
        case longDateTime
        case shortDateTime
        case longDate
        case shortDate
        case longTime
        case shortTime

        var formatStr: String {
            switch self {
            case .longDateTime: return "yyyy-MM-dd HH:mm:ss"
            case .shortDateTime: return "yyyyMMddHHmm"
            case .longDate: return "yyyy-MM-dd"
            case .shortDate: return "yyyyMMdd"
            case .longTime: return "HH:mm:ss"
            case .shortTime: return "HHmm"
            }
        }
    }

    func string(ofFormat format: DNDateTimeFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.formatStr
        return formatter.string(from: self)
    }
}

public extension Date {
    static func compare(_ lh: Date?, _ rh: Date?) -> Bool {
        guard let lh = lh, let rh = rh else { return true }
        return lh > rh
    }
}
