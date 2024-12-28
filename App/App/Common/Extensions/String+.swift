//
//  String+.swift
//  Nest0
//
//  Created by Yongsik Kim on 2021/07/15.
//

import Foundation

// MARK: - localization

public extension String {
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        String(format: localized, locale: .current, arguments: args)
    }
}

// MARK: - remove char

public extension String {
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }

    func removeCharacters(from: String) -> String {
        removeCharacters(from: CharacterSet(charactersIn: from))
    }

    var digits: String {
        components(separatedBy: .decimalDigits.inverted).joined()
    }
}

// MARK: - utilities

public extension String {
    var hasContent: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

// MARK: - log

public extension String {
    @discardableResult func ld() -> String {
#if DEBUG
        AppLogger.shared.logPublic(self, level: .debug)
#endif
        return self
    }

    @discardableResult func li() -> String {
#if DEBUG
        AppLogger.shared.logPublic(self, level: .info)
#endif
        return self
    }

    @discardableResult func l() -> String {
#if DEBUG
        AppLogger.shared.logPublic(self, level: .default)
#endif
        return self
    }

    @discardableResult func le() -> String {
        AppLogger.shared.logPublic(self, level: .error)
        return self
    }

    @discardableResult func lf() -> String {
        AppLogger.shared.logPublic(self, level: .fault)
        return self
    }

    @discardableResult func lxd() -> String {
        AppLogger.shared.logPublic(self, level: .debug)
        return self
    }

    @discardableResult func lxi() -> String {
        AppLogger.shared.logPrivate(self, level: .info)
        return self
    }

    @discardableResult func lx() -> String {
        AppLogger.shared.logPrivate(self, level: .default)
        return self
    }

    @discardableResult func lxe() -> String {
        AppLogger.shared.logPrivate(self, level: .error)
        return self
    }

    @discardableResult func lxf() -> String {
        AppLogger.shared.logPrivate(self, level: .fault)
        return self
    }

    @discardableResult func ld(_ tag: String) -> String {
#if DEBUG
        AppLogger.shared.logPublic(tag + "] " + self, level: .debug)
#endif
        return self
    }

    @discardableResult func li(_ tag: String) -> String {
#if DEBUG
        AppLogger.shared.logPublic(tag + "] " + self, level: .info)
#endif
        return self
    }

    @discardableResult func l(_ tag: String) -> String {
#if DEBUG
        AppLogger.shared.logPublic(tag + "] " + self, level: .default)
#endif
        return self
    }

    @discardableResult func le(_ tag: String) -> String {
        AppLogger.shared.logPublic(tag + "] " + self, level: .error)
        return self
    }

    @discardableResult func lf(_ tag: String) -> String {
        AppLogger.shared.logPublic(tag + "] " + self, level: .fault)
        return self
    }

    @discardableResult func lxd(_ tag: String) -> String {
        AppLogger.shared.logPublic(tag + "] " + self, level: .debug)
        return self
    }

    @discardableResult func lxi(_ tag: String) -> String {
        AppLogger.shared.logPrivate(tag + "] " + self, level: .info)
        return self
    }

    @discardableResult func lx(_ tag: String) -> String {
        AppLogger.shared.logPrivate(tag + "] " + self, level: .default)
        return self
    }

    @discardableResult func lxe(_ tag: String) -> String {
        AppLogger.shared.logPrivate(tag + "] " + self, level: .error)
        return self
    }

    @discardableResult func lxf(_ tag: String) -> String {
        AppLogger.shared.logPrivate(tag + "] " + self, level: .fault)
        return self
    }
}

// MARK: - DefaultStringInterpolation

/// to depress "String interpolation... warning"
/// can be used like this : print("this is optinal string \(o: optStr)")
public extension DefaultStringInterpolation {
    mutating func appendInterpolation<T>(o: T?) {
        appendInterpolation(String(describing: o))
    }
}

// MARK: - utilities

public extension String {
    func contains(_ strings: [String]) -> Bool {
        strings.first(where: { self.contains($0) }) != nil
    }
    
    func character(at position: Int) -> String {
        guard position < count else { return "" }
        let index = index(startIndex, offsetBy: position)
        return String(self[index])
    }
    
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

// MARK: - format validation
public extension String {
    var isNumber: Bool {
        let characters = CharacterSet.decimalDigits
        return CharacterSet(charactersIn: self).isSubset(of: characters)
    }
}

// MARK: - etc
public extension String {
    func urlEncoded(encodeParams: Bool = false) -> String? {
        addingPercentEncoding(withAllowedCharacters: encodeParams ? .urlHostAllowed : .urlQueryAllowed)
    }
    
    func urlDecoded() -> String? {
        self.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
    }
}
