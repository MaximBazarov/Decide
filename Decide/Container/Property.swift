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

/// Managed by ``ApplicationEnvironment`` storage for values that can be observed and mutated.
/// 
/// TBD: how to access and mutate.
@propertyWrapper
@MainActor public final class Property<Value> {

    private(set) var valueContainer: ValueContainer<Value>
    let defaultValue: () -> Value

    /// Default Value
    public var wrappedValue: Value {
        get {
            if let value = valueContainer.value { return value }
            let newValue = defaultValue()
            valueContainer.value = newValue
            return newValue
        }
        set {
            valueContainer.value = newValue
        }
    }

    public var projectedValue: Property<Value> {
        self
    }

    public init(wrappedValue: @autoclosure @escaping () -> Value, file: StaticString = #fileID, line: UInt = #line) {
        self.valueContainer = ValueContainer()
        self.defaultValue = wrappedValue
        self.file = file.description
        self.line = line
    }

    // MARK: - Tracing
    let file: String
    let line: UInt
}
