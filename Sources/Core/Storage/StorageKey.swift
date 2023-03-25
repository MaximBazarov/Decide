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

/// A unique (during session) identifier of the value in the ``StorageSystem``.
/// The identifier will not necessarily be the same among app instances/sessions.
public final class StorageKey: Hashable, CustomDebugStringConvertible {
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
// MARK: Hashable (Equitable)
//===----------------------------------------------------------------------===//

public extension StorageKey {
    func hash(into hasher: inout Hasher) {
        hasher.combine(typeKey)
        additionalKeys.forEach { hasher.combine($0) }
    }
}

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
    public var debugDescription: String {
        return Self.pretty(_typeName) + "  \(self.additionalKeys.map{ $0.debugDescription }.joined(separator: ", "))"
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
