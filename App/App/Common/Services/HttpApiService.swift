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
        Task {
            await setCommomHeader(forKey: "Content-Type", value: "application/json")
        }
    }

    /// common header
    public private(set) var commonHeaders: [String: String] = [:]

    public func setCommomHeader(forKey key: String, value: String) {
        commonHeaders[key] = value
    }

    private lazy var defaultSession: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 60.0
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

    private func sendDataRequest(url: URL) async throws -> (Data, HttpCode) {
        let (data, response) = try await defaultSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            let errMsg = "invalid response : \(response)".le(T)
            throw AppError.invalidResponse(errMsg)
        }

        let code = httpResponse.statusCode
        "Response code = \(code), body = \(o: data.prettyPrintedJSONString)".ld(T)

        return (data, HttpCode(rawValue: code))
    }

    private func sendUrlRequest(request: URLRequest) async throws -> (Data, HttpCode) {
        let (data, response) = try await defaultSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            let errMsg = "invalid response : \(response)".le(T)
            throw AppError.invalidResponse(errMsg)
        }

        let code = httpResponse.statusCode
        "Response code = \(code), body = \(o: data.prettyPrintedJSONString)".ld(T)

        return (data, HttpCode(rawValue: code))
    }

    public func get<M: Codable>(from urlStr: String) async throws -> M {
        "GET: \(urlStr)".ld(T)

        let url = try url(from: urlStr)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        commonHeaders.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        let (data, code) = try await sendUrlRequest(request: request)

        if code.isSuccess {
            let decoder = JSONDecoder()
            let result = try decoder.decode(M.self, from: data)
            return result
        }

        throw AppError.httpError(code)
    }

    public func get(from urlStr: String) async throws -> Data {
        "GET data: \(urlStr)".ld(T)

        let url = try url(from: urlStr)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        commonHeaders.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        let (data, code) = try await sendUrlRequest(request: request)

        if code.isSuccess {
            return data
        }

        throw AppError.httpError(code)
    }
}
