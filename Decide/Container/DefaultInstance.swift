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

/// Managed by ``ApplicationEnvironment`` storage for objects, unlike ``Property`` it doesn't support mutation nor observation.
@propertyWrapper
@MainActor public final class DefaultInstance<O> {
    public var wrappedValue: O {
        get {
            if let storage { return storage }
            let newValue = defaultValue()
            storage = newValue
            return newValue
        }
    }
    
    public var projectedValue: DefaultInstance<O> {
        self
    }
    
    public init(wrappedValue: @autoclosure @escaping () -> O, file: StaticString = #fileID, line: UInt = #line) {
        self.defaultValue = wrappedValue
        self.file = file.description
        self.line = line
    }
    
    // MARK: - Value Storage
    private var storage: O?
    private let defaultValue: () -> O
    
    // MARK: - Tracing
    let file: String
    let line: UInt
}

