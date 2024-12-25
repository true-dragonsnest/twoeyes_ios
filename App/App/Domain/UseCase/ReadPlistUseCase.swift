//
//  ReadPlistUseCase.swift
//  App
//
//  Created by Yongsik Kim on 12/24/24.
//

import Foundation

extension UseCases {
    enum ReadPlist {
        static func execute(fileName: String, key: String) -> String {
            guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist")
            else {
                fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: key) as? String else {
                fatalError("Couldn't find key \(key) in '\(fileName).plist'.")
            }
            if value.starts(with: "_") || value.isEmpty {
                fatalError("Invalid value for key \(key): \(value).")
            }
            return value
        }
    }
}
