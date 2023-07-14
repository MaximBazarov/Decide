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
    
    public var projectedValue: Property<Value> {
        self
    }
    
    public init(wrappedValue: @autoclosure @escaping () -> Value, file: StaticString = #fileID, line: UInt = #line) {
        self.defaultValue = wrappedValue
        self.file = file.description
        self.line = line
    }
    
    // MARK: - Value Storage
    var storage: Value?
    let defaultValue: () -> Value

    // MARK: - Observation
    var observations = ObservationSystem() // keep it `var` to be isolated

    func addObserver(_ observer: ObservableValue) {
        observations.subscribe(observer)
    }
    
    // MARK: - Tracing
    let file: String
    let line: UInt
}
