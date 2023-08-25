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


/// Incapsulated a container and a new value.
/// Value later is used to apply on environment
/// using `.mutate()` or `.popObservers()`.
final class Transaction: Hashable {

    /// We store the ``ValueContainer`` KeyPath for the transaction identity.
    let keyPath: AnyKeyPath

    /// called later when changes new value needs to be written in provided environment.
    let mutate: (ApplicationEnvironment) -> Void
    /// called later when observers of the container in the given environment are needed.
    let popObservers: (ApplicationEnvironment) -> Set<Observer>


    /// Instantiates a transaction of writing a `newValue` at `containerKeyPath`.
    /// - Parameters:
    ///   - containerKeyPath: ``ValueContainer`` KeyPath
    ///   - newValue: Value to be written.
    @MainActor init<S: AtomicState, V>(
        _ propertyKeyPath: KeyPath<S, Property<V>>,
        newValue: V
    ) {
        // We don't want Transaction to inherit generic of V in ValueContainer<V>,
        // so instead of storing the container we pack it into closures that are
        // of non-generic types and can be later provided with the environment.
        self.mutate = { environment in
            environment.setValue(newValue, propertyKeyPath)
        }
        self.popObservers = { environment in
            environment.popObservers(propertyKeyPath)
        }
        self.keyPath = propertyKeyPath
    }

    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.keyPath == rhs.keyPath
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
    }
}
