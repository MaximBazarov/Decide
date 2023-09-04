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


/// Marks property as mutable, to use in bindings e.g. ``Bind``
@propertyWrapper @MainActor public final class Mutable<Value>: PropertyModifier {
    private(set) public var wrappedValue: Property<Value>
    public var projectedValue: Mutable<Value> { self }
    public init(wrappedValue: Property<Value>) {
        self.wrappedValue = wrappedValue
    }
}


public extension Bind {

    /// Two way binding to the given ``Mutable`` property KeyPath
    init(
        _ keyPath: KeyPath<State, Mutable<Value>>,
        file: String = #fileID,
        line: Int = #line
    ) {
        self.context = Context(file: file, line: line)
        self.propertyKeyPath = keyPath.appending(path: \.wrappedValue)
    }
}

extension BindKeyed {
    /// Two way binding to the given ``Mutable`` in ``KeyedState`` property KeyPath
    public init(
        _ propertyKeyPath: KeyPath<State, Mutable<Value>>,
        file: String = #fileID,
        line: Int = #line
    ) {
        let context = Context(file: file, line: line)
        self.context = context
        self.propertyKeyPath = propertyKeyPath.appending(path: \.wrappedValue)
    }
}
