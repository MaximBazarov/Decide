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

@propertyWrapper
@MainActor public final class Property<Value> {

    var storage: Value?
    let defaultValue: () -> Value

    let observations = ObservationSystem()

    func addObserver(_ observer: ObservableValue) {
        observations.subscribe(observer)
    }

    public var wrappedValue: Value {
        get {
            if let storage { return storage }
            let newValue = defaultValue()
            storage = newValue
            return newValue
        }
        set {
            observations.valueDidChange()
            storage = newValue
        }
    }

    public var projectedValue: Property<Value> { self }

    let file: String
    let line: UInt

    public init(wrappedValue: @autoclosure @escaping () -> Value, file: StaticString = #fileID, line: UInt = #line) {
        self.defaultValue = wrappedValue
        self.file = file.description
        self.line = line
    }
}

/// Typealias to distinguish state values and instances. See ``Property``.
public typealias DefaultInstance = Property
