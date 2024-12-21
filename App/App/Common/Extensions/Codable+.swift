//
//  Codable+.swift
//  Nest0
//
//  Created by Yongsik Kim on 2021/08/30.
//

import Foundation

/// set this flag `true` when timestamp is in msec.
private let msecTimeStamp: Bool = true

public extension Decodable {
    static func decode<T: Decodable>(fromJsonStr jsonStr: String, decoder: JSONDecoder? = nil) throws -> T? {
        guard let jsonData = jsonStr.data(using: .utf8) else {
            let e = "invalid JSON string : \(jsonStr)".le()
            throw AppError.generalError(e)
        }

        return try decode(fromData: jsonData, decoder: decoder)
    }

    static func decode<T: Decodable>(fromJsonDic jsonDic: [String: Any], decoder: JSONDecoder? = nil) throws -> T {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDic) else {
            let e = "invalid JSON dictionary : \(jsonDic)".le()
            throw AppError.generalError(e)
        }

        return try decode(fromData: jsonData, decoder: decoder)
    }

    static func decode<T: Decodable>(fromData jsonData: Data, decoder: JSONDecoder? = nil) throws -> T {
        do {
            let decoder = decoder ?? JSONDecoder()
            if msecTimeStamp {
                decoder.dateDecodingStrategy = .millisecondsSince1970
            }
            let model = try decoder.decode(T.self, from: jsonData)
            return model
        } catch let error as NSError {
            throw AppError(error)
        }
    }
}

public extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

    func dataPrettyPrinted() throws -> Data {
        try JSONEncoder.iso8601PrettyPrinted.encode(self)
    }

    var jsonPrettyPrinted: NSString? {
        do {
            let data = try dataPrettyPrinted()
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        } catch {
            "json: invalid data format: \(error)".le()
            return nil
        }
    }
}
