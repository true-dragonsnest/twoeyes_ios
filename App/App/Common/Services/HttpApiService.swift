//
//  HttpApiService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/11/16.
//

import Foundation

private let T = #fileID

public actor HttpApiService {
    /// http code
    public enum HttpCode: CustomStringConvertible {
        case ok
        case created
        case accepted
        case badRequest
        case unauthorized
        case notFound
        case internalServerError
        case unknown(Int)

        public init(rawValue: Int) {
            switch rawValue {
            case 200:
                self = .ok
            case 201:
                self = .created
            case 202:
                self = .accepted
            case 400:
                self = .unauthorized
            case 404:
                self = .notFound
            case 500:
                self = .internalServerError
            default:
                self = .unknown(rawValue)
            }
        }

        public var description: String {
            switch self {
            case .ok: return "OK (200)"
            case .created: return "CREATED (201)"
            case .accepted: return "ACCEPTED (202)"
            case .badRequest: return "BadRequest (400)"
            case .unauthorized: return "Unauthorized (401)"
            case .notFound: return "NotFound (404)"
            case .internalServerError: return "InternalServerError (500)"
            case let .unknown(code): return "Unknown (\(code))"
            }
        }

        public var isSuccess: Bool {
            switch self {
            case .ok, .created, .accepted: return true
            default: return false
            }
        }
    }

    /// shared instance
    public static let shared = HttpApiService()

    private init() {
        commonHeaders["Content-Type"] = "application/json"
    }
    
    public lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    public lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// common header
    public private(set) var commonHeaders: [String: String] = [:]

    public func setCommomHeader(forKey key: String, value: String) {
        commonHeaders[key] = value
    }

    private lazy var defaultSession: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 3600.0
        return URLSession(configuration: sessionConfig)
    }()

    private nonisolated func url(from urlStr: String) throws -> URL {
        if let decoded = urlStr.urlDecoded(), decoded != urlStr {
            "ALREADY encoded? : \(urlStr)".ld(T)
            guard let url = URL(string: urlStr) else {
                throw AppError.invalidRequest("invalid URL : \(urlStr)".le(T))
            }
            return url
        }
        guard let encoded = urlStr.urlEncoded(), let url = URL(string: encoded) else {
            throw AppError.invalidRequest("invalid URL : \(urlStr)".le(T))
        }
        return url
    }
    
    private func sendUrlRequest(request: URLRequest, logLevel: Int) async throws -> (Data, HttpCode) {
        let (data, response) = try await defaultSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            let errMsg = "invalid response : \(response)".le(T)
            throw AppError.invalidResponse(errMsg)
        }

        let code = httpResponse.statusCode
        if logLevel > 1 {
            //"Request to \(o: request.url?.absoluteString), body = \(o: request.httpBody?.prettyPrintedJSONString), header = \(o: request.allHTTPHeaderFields) -> \(code), body = \(o: data.prettyPrintedJSONString)".ld(T)
            "Request to \(o: request.url?.absoluteString), header = \(o: request.allHTTPHeaderFields) -> \(code), body = \(o: data.prettyPrintedJSONString)".ld(T)
        } else if logLevel > 0 {
            "Response code = \(o: request.url?.absoluteString) -> \(code)".ld(T)
        }

        return (data, HttpCode(rawValue: code))
    }
    
    private enum UrlRequestMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    private func performUrlRequest(method: UrlRequestMethod,
                                   urlStr: String,
                                   bodyData: Data? = nil,
                                   logLevel: Int) async throws -> (Data, HttpCode)
    {
        if logLevel > 0 { "\(method.rawValue) : \(urlStr)".ld(T) }
        
        let url = try url(from: urlStr)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let bodyData {
            request.httpBody = bodyData
        }
        request.cachePolicy = .useProtocolCachePolicy   // FIXME: use .returnCacheDataElseLoad by option
        commonHeaders.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        return try await sendUrlRequest(request: request, logLevel: logLevel)
    }

    public func get<M: Codable>(from urlStr: String, logLevel: Int = 1) async throws -> M {
        let (data, code) = try await performUrlRequest(method: .get, urlStr: urlStr, logLevel: logLevel)
        guard code.isSuccess else {
            throw AppError.httpError(code)
        }
        return try decoder.decode(M.self, from: data)
    }

    public func get(from urlStr: String, logLevel: Int = 1) async throws -> Data {
        let (data, code) = try await performUrlRequest(method: .get, urlStr: urlStr, logLevel: logLevel)
        guard code.isSuccess else {
            throw AppError.httpError(code)
        }
        return data
    }
    
    public func post<M: Encodable, N: Decodable>(entity: M, to urlStr: String, logLevel: Int = 1) async throws -> N {
        let bodyData = try encoder.encode(entity)
        let (data, code) = try await performUrlRequest(method: .post, urlStr: urlStr, bodyData: bodyData, logLevel: logLevel)
        guard code.isSuccess else {
            throw AppError.httpError(code)
        }
        return try decoder.decode(N.self, from: data)
    }
}
