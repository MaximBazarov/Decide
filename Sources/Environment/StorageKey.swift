//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation


/// A compound and unique identifier used to distinguish stored values within ``Storage``.
/// Enables a flexible value identification by combining a type and optionally additional keys and a URI.
/// > Note: The uniqueness of the keys is guaranteed **only within the storage system**;
/// Provide a URI to guarantee uniqueness across different systems such as file system or Core Data.
public final class StorageKey: Hashable, CustomDebugStringConvertible {

    // value identity
    private let localKey: AnyHashable
    private let additionalKeys: [AnyHashable]


    /// Unique Resource Identifier - identifies a value across different environments such as file system, core data, iCloud etc.
    public let uri: String?

    // used for debugging only
    private let _typeName: String

    /// Creates a key from a provided type, using its `ObjectIdentifier`.
    ///
    /// - Parameters:
    ///     - type: The specified type
    ///     - additionalKeys: *Optional:* An array of additional keys that will help identify the value in storage.
    ///     - uri: *Optional:* **Unique Resource Identifier**, a string that uniquely identifies a value across multiple systems, such as database storage, cloud storage synchronization, or file system storage.
    init<T>(type: T.Type, additionalKeys: [AnyHashable] = [], uri: String? = nil) {
        self.localKey = ObjectIdentifier(type.self)
        self._typeName = String(reflecting: type)
        self.additionalKeys = additionalKeys
        self.uri = uri
    }

    public static func == (lhs: StorageKey, rhs: StorageKey) -> Bool {
        guard lhs.additionalKeys.count == rhs.additionalKeys.count
        else { return false }

        var result = lhs.localKey == rhs.localKey
        for index in lhs.additionalKeys.indices {
            result = result
            && lhs.additionalKeys[index] == rhs.additionalKeys[index]
        }
        result = result && (lhs.uri == rhs.uri)
        return result
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(localKey)
        additionalKeys.forEach { hasher.combine($0) }
        hasher.combine(uri)
    }

    public var debugDescription: String {
        let local = Self.pretty(_typeName)
        let additional = self.additionalKeys
            .map{ $0.debugDescription }
            .joined(separator: ", ")

        if let uri = uri {
            return  uri + " (\(local)" + (self.additionalKeys.count > 0 ? ", " + additional : "")
        }

        return local + (self.additionalKeys.count > 0 ? " " + additional : "")
    }

    static func pretty(_ value: String) -> String {
        let str = value
            .replacingOccurrences(of: "ObjectIdentifier", with: "")
            .replacingOccurrences(of: "AnyHashable", with: "")
            .replacingOccurrences(of: "((", with: "(")
            .replacingOccurrences(of: "))", with: ")")
            .split(separator: ".")
            .suffix(1)
            .joined(separator: ".")


        return String(str)
    }
}

private extension AnyHashable {
    var debugDescription: String {
        return String(reflecting: self)
            .replacingOccurrences(of: "AnyHashable", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
}
