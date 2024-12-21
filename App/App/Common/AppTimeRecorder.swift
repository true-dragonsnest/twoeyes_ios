//
//  AppTimeRecorder.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/01/28.
//

import Foundation

private let T = #fileID

public class AppTimeRecorder {
    private(set) var records: [(String, UInt64)] = []
    private var lastTimeStamp: UInt64 = 0

    public init() {
        start()
    }

    public func start() {
        records = []
        lastTimeStamp = Self.getMsec()
    }

    public func ticktick(_ label: String?) {
        let now = Self.getMsec()
        records.append((label ?? "record #\(records.count)", now - lastTimeStamp))
        lastTimeStamp = now
    }

    public var prettyPrinted: String {
        "{\n" + records.map { "\($0.0) : \($0.1) msec" }.joined(separator: ",\n") + "\n}"
    }

    public static func getMsec() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds / 1_000_000
    }
}
