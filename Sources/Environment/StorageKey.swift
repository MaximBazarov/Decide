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
///
/// > Warning: It's easy to create two states that have different Value type, but still the same URI.
/// Which would lead to Value type mismatch when reading from storage.
public final class StorageKey: Hashable, CustomDebugStringConvertible {

    /// A computed property representing the
    /// **Unique Resource Identifier** (URI) of the stored value.
    ///
    /// The URI is a string that uniquely identifies a value
    /// across multiple systems, such as database storage,
    /// cloud storage synchronization, or file system storage.
    ///
    /// > Note: It can be `nil` if the key doesn't support persistency.
    public var uri: String?
    /// Creates a key from a provided type, using its `ObjectIdentifier`.
    ///
    /// - Parameters:
    ///   - type: The specified type
    ///   - additionalKeys: *Optional:* An array of additional keys that will help identify the value in storage.
    public init<T>(type: T.Type, additionalKeys: [AnyHashable] = []) {
        self.type = .type(
            typeID: ObjectIdentifier(type.self),
            additionalKeys: additionalKeys
        )

        self.debugName = String(reflecting: type)
    }

    /// Creates a key from a provided URI.
    ///
    /// - Parameters:
    ///   - URI: **Unique Resource Identifier**, a string that uniquely
    ///   identifies a value across multiple systems,
    ///   such as database storage, cloud storage synchronization,
    ///   or file system storage.
    public init(uri: String) {
        self.type = .persistent(uri: uri)
        self.debugName = uri
    }

    // MARK: - Internal -
    enum KeyType {
        ///A state type based compound and unique identifier used to distinguish stored values within ``Storage``.
        case type(typeID: ObjectIdentifier, additionalKeys: [AnyHashable])

        /// Based on Unique Resource Identifier - identifies a value across different environments such as file system, core data, iCloud etc.
        case persistent(uri: String)
    }

    let type: KeyType

    // Contains a type name or uri, used for debugging only.
    private let debugName: String

    public static func == (lhs: StorageKey, rhs: StorageKey) -> Bool {
        switch (lhs.type, rhs.type) {
        case let (
            .type(lhsTypeID, lhsAdditionalKeys),
            .type(rhsTypeID, rhsAdditionalKeys)):
            return lhsTypeID == rhsTypeID
            && lhsAdditionalKeys == rhsAdditionalKeys
        case let (.persistent(lhsURI), .persistent(rhsURI)):
            return lhsURI == rhsURI
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch type {
        case let .type(typeID, additionalKeys):
            hasher.combine(typeID)
            hasher.combine(additionalKeys)
        case let .persistent(uri):
            hasher.combine(uri)
        }
    }

    public var debugDescription: String {
        switch type {
        case let .type(_, additionalKeys):
            var title: String = debugName
                .replacingOccurrences(of: "ObjectIdentifier", with: "")
                .replacingOccurrences(of: "AnyHashable", with: "")
                .replacingOccurrences(of: "((", with: "(")
                .replacingOccurrences(of: "))", with: ")")
                .split(separator: ".")
                .suffix(1)
                .joined(separator: ".")

            // title += " (\(typeID))"
            if additionalKeys.count > 0 {
                title += ", "
                title += additionalKeys
                    .map{ $0.debugDescription }
                    .joined(separator: ", ")
            }
            return title
        case let .persistent(uri):
            return uri
        }
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
