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

@MainActor public protocol EnvironmentObservingObject: EnvironmentManagedObject {
    @MainActor func environmentDidUpdate()
}

/// Property wrapper to access default environment,
/// to be used on ``EnvironmentManagedObject`` and ``EnvironmentObservingObject``.
///
/// Usage:
/// ```swift
/// @DefaultEnvironment var environment
/// ```
@MainActor @propertyWrapper public final class DefaultEnvironment {
    public var wrappedValue: ApplicationEnvironment = .default
    public init() {}

    @MainActor final class ObservationSystem {
        var subscriberStorage: Set<WeakEnvironmentObservingObject> = []

        func subscribe(
            _ object: EnvironmentObservingObject
        ) {
            let weakObject = WeakEnvironmentObservingObject(object)
            guard subscriberStorage.contains(weakObject) else {
                subscriberStorage.insert(weakObject)
                return
            }
            subscriberStorage.insert(weakObject)
        }

        func didChangeValue() {
            subscriberStorage.forEach({ subscriber in
                subscriber.value?.environmentDidUpdate()
            })

            subscriberStorage = []
        }
    }

    final class WeakEnvironmentObservingObject: Hashable {
        weak var value: EnvironmentObservingObject?

        init(_ value: EnvironmentObservingObject) {
            self.value = value
        }

        static func == (lhs: WeakEnvironmentObservingObject, rhs: WeakEnvironmentObservingObject) -> Bool {
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
    }
}
