//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import Foundation
//===----------------------------------------------------------------------===//
// MARK: - Storage Key
//===----------------------------------------------------------------------===//

/// A unique identifier of the value in the ``StorageSystem``
public final class StorageKey: Hashable, CustomDebugStringConvertible {
    public var debugDescription: String {
        let id = Self.stripTypes(typeKey)
        return "\(_typeName) \(id)"
    }

    let typeKey: AnyHashable
    let additionalKeys: [AnyHashable]

    private let _typeName: String

    init<T>(type: T.Type, additionalKeys: [AnyHashable]) {
        self.typeKey = ObjectIdentifier(type.self)
        self._typeName = String(reflecting: type)
        self.additionalKeys = additionalKeys
    }
}

//===----------------------------------------------------------------------===//
// MARK: Hashable
//===----------------------------------------------------------------------===//

public extension StorageKey {
    func hash(into hasher: inout Hasher) {
        hasher.combine(typeKey)
        additionalKeys.forEach { hasher.combine($0) }
    }
}

//===----------------------------------------------------------------------===//
// MARK: Equitable
//===----------------------------------------------------------------------===//

public extension StorageKey {
    static func == (lhs: StorageKey, rhs: StorageKey) -> Bool {
        guard lhs.additionalKeys.count == rhs.additionalKeys.count
        else { return false }

        var result = lhs.typeKey == rhs.typeKey
        for index in lhs.additionalKeys.indices {
            result = result
            && lhs.additionalKeys[index] == rhs.additionalKeys[index]
        }
        return result
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Debug
//===----------------------------------------------------------------------===//

extension StorageKey {
    static func stripTypes(_ value: AnyHashable) -> String {
        value
            .debugDescription
            .replacingOccurrences(of: "ObjectIdentifier", with: "")
            .replacingOccurrences(of: "AnyHashable", with: "")
            .replacingOccurrences(of: "((", with: "(")
            .replacingOccurrences(of: "))", with: ")")
    }
}
