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
/// Managed by ``ApplicationEnvironment`` storage for objects, unlike ``ObservableState`` it doesn't support mutation nor observation.
@propertyWrapper
@MainActor public final class DefaultInstance<Object> {
    public var wrappedValue: Object {
        get {
            if let storage { return storage }
            let newValue = defaultValue()
            storage = newValue
            return newValue
        }
    }

    public var projectedValue: DefaultInstance<Object> {
        self
    }

    public init(wrappedValue: @autoclosure @escaping () -> Object, file: StaticString = #fileID, line: UInt = #line) {
        self.defaultValue = wrappedValue
        self.file = file.description
        self.line = line
    }

    // MARK: - Value Storage
    private var storage: Object?
    private let defaultValue: () -> Object

    // MARK: - Tracing
    let file: String
    let line: UInt
}
