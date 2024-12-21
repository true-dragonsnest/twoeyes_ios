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

    /// GET from URL
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

    private enum DownloadStatus {
        case inProgress(Task<Data, Error>)
        case completed(Data)
    }

    private var downloadRequests: [String: DownloadStatus] = [:]

    private func download(_ urlRequest: URLRequest, cacheKey: String?) async throws -> Data {
        if let cacheKey = cacheKey {
            if let status = downloadRequests[cacheKey] {
                switch status {
                case let .inProgress(task):
                    return try await task.value
                case let .completed(data):
                    return data
                }
            }

            // TODO: query local storage cache
        }

        let fetchTask: Task<Data, Error> = Task {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let httpCode = HttpCode(rawValue: (response as? HTTPURLResponse)?.statusCode ?? 500)
            guard httpCode.isSuccess else {
                throw AppError.httpError(httpCode)
            }
            // TODO: save to local storage cache
            return data
        }

        if let cacheKey = cacheKey {
            downloadRequests[cacheKey] = .inProgress(fetchTask)
        }
        let data = try await fetchTask.value
        if let cacheKey = cacheKey {
            downloadRequests[cacheKey] = .completed(data)
        }

        return data
    }
}

public extension HttpApiService {
    func download(from urlStr: String, cacheKey: String? = nil) async throws -> Data {
        "DOWNLOAD: \(urlStr)".ld(T)

        let url = try url(from: urlStr)
        return try await download(URLRequest(url: url), cacheKey: cacheKey)
    }
}
