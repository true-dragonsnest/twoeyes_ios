//
//  String+HtmlDecode.swift
//  App
//
//  Created by Assistant on 1/11/25.
//

import Foundation

extension String {
    var htmlDecoded: String {
        let htmlEntities = [
            "&quot;": "\"",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&apos;": "'",
            "&#39;": "'",
            "&#x27;": "'",
            "&#x2F;": "/",
            "&#x60;": "`",
            "&#x3D;": "="
        ]
        
        var result = self
        for (entity, character) in htmlEntities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        
        // Handle numeric entities
        let pattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: result),
                   let codeRange = Range(match.range(at: 1), in: result),
                   let code = Int(result[codeRange]),
                   let scalar = UnicodeScalar(code) {
                    result.replaceSubrange(range, with: String(Character(scalar)))
                }
            }
        }
        
        return result
    }
}