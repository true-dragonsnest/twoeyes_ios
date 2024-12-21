//
//  AppError.swift
//  Nest0
//
//  Created by Yongsik Kim on 2021/08/01.
//

import Foundation

public enum AppError: Error {
    case error(_ error: Error)
    case generalError(_ message: String? = nil)
    case aborted(_ message: String? = nil)
    case bug(_ message: String? = nil)
    case notImplemented(_ message: String? = nil)
    case notInited(_ message: String? = nil)

    case notAllowed(_ message: String? = nil)
    case notFound(_ message: String? = nil)
    case canceled(_ message: String? = nil)
    case expired(_ message: String? = nil)
    case alreadyExists(_ message: String? = nil)
    case accessDenied(_ message: String? = nil)

    case needLogin(_ message: String? = nil)
    case invalidRequest(_ message: String? = nil)
    case invalidResponse(_ message: String? = nil)
    case httpError(_ code: HttpApiService.HttpCode)

    case storageWriteFailure(_ message: String? = nil, error: Error?)

    case overMaxLimit(_ message: String? = nil)

    public func string() -> String {
        switch self {
        case let .error(error): return error.localizedDescription
        case let .generalError(message): return "General error : \(o: message)"
        case let .aborted(message): return "Aborted : \(o: message)"
        case let .bug(message): return "Bug : \(o: message)"
        case let .notImplemented(message): return "Not implemented : \(o: message)"
        case let .notInited(message): return "Not inited : \(o: message)"
        case let .notAllowed(message): return "Not allowed : \(o: message)"
        case let .needLogin(message): return "Need login : \(o: message)"
        case let .invalidRequest(message): return "Invalid request : \(o: message)"
        case let .invalidResponse(message): return "Invalid response : \(o: message)"
        case let .httpError(code): return "HTTP Error : code = \(code)"
        case let .notFound(message): return "Not found : \(o: message)"
        case let .canceled(message): return "Canceled : \(o: message)"
        case let .expired(message): return "Expired : \(o: message)"
        case let .alreadyExists(message): return "Already Exists : \(o: message)"
        case let .accessDenied(message): return "Access denied : \(o: message)"
        case let .storageWriteFailure(message, error): return "Storage Write Failure : \(o: message), error = \(o: error)"
        case let .overMaxLimit(message): return "Over max bookmark counts: \(o: message)"
        }
    }

    public func message() -> String? {
        switch self {
        case let .error(error): return error.localizedDescription
        case let .generalError(message): return message
        case let .aborted(message): return message
        case let .bug(message): return message
        case let .notImplemented(message): return message
        case let .notInited(message): return message
        case let .notAllowed(message): return message
        case let .needLogin(message): return message
        case let .invalidRequest(message): return message
        case let .invalidResponse(message): return message
        case let .httpError(code): return code.description
        case let .notFound(message): return message
        case let .canceled(message): return message
        case let .expired(message): return message
        case let .alreadyExists(message): return message
        case let .accessDenied(message): return message
        case let .storageWriteFailure(message, _): return message
        case let .overMaxLimit(message): return message
        }
    }
}

public extension AppError {
    init(_ error: Error) {
        self = error as? AppError ?? .error(error)
    }
}
