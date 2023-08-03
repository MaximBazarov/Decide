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
