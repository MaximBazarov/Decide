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

/// Modifier applied to property to change it bechaviour e.g ``Mutable`` alows property to be directly mutated through bindings e.g. ``Bind``.
@MainActor public protocol PropertyModifier {
    associatedtype Value
    var wrappedValue: Property<Value> { get }
}

extension Observe {
    
    /// Observe reading ``PropertyModifier`` on ``AtomicState``.
    public init<WrappedProperty: PropertyModifier>(
        _ propertyKeyPath: KeyPath<State, WrappedProperty>
    ) where WrappedProperty.Value == Value {
        self.containerKeyPath = .property(propertyKeyPath.appending(path: \.wrappedValue))
    }
}

public extension ObserveKeyed {
    
    /// Observe reading ``PropertyModifier`` on ``KeyedState``
    init<WrappedProperty: PropertyModifier>(
        _ propertyKeyPath: KeyPath<State, WrappedProperty>
    ) where WrappedProperty.Value == Value {
        self.containerKeyPath = .property(propertyKeyPath.appending(path: \.wrappedValue))
    }
}

public extension DefaultObserveKeyed {
    init<ModifiedProperty: PropertyModifier>(
        _ keyPath: KeyPath<State, ModifiedProperty>
    ) where ModifiedProperty.Value == Value {
        self.containerKeyPath = .property(keyPath.appending(path: \.wrappedValue))
    }
}
