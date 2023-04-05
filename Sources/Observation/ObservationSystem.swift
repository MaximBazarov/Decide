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

//===----------------------------------------------------------------------===//
// MARK: - Observation System
//===----------------------------------------------------------------------===//


/// One-time pass Observation System
@MainActor final class ObservationSystem {
    let storage = ObservableValueStorage()

    func subscribe(_ observableValue: ObservableValue, to key: StorageKey) {
        storage.add(observableValue, for: key)
    }

    func pop(observationsOf key: StorageKey) -> Set<ObservableValue> {
        storage.pop(observationsOf: key)
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Storage
//===----------------------------------------------------------------------===//

final class ObservableValueStorage {

    final class WeakRef: Hashable {
        weak var ref: ObservableValue?
        init(_ ref: ObservableValue) {
            self.ref = ref
        }

        static func == (lhs: ObservableValueStorage.WeakRef, rhs: ObservableValueStorage.WeakRef) -> Bool {
            lhs.ref == rhs.ref
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(ref)
        }
    }

    var storage: [StorageKey: Set<WeakRef>] = [:]

    func add(_ observation: ObservableValue, for key: StorageKey) {
        var observationsOfKey = storage[key] ?? []
        observationsOfKey.insert(WeakRef(observation))
        storage[key] = observationsOfKey
    }

    func pop(observationsOf key: StorageKey) -> Set<ObservableValue> {
        let observations = storage[key] ?? []
        storage.removeValue(forKey: key)
        return Set(observations.compactMap(\.ref))
    }

    func pop(observationsOf keys: Set<StorageKey>) -> Set<ObservableValue> {
        var values = Set<ObservableValue>()
        for key in keys {
            values.formUnion(pop(observationsOf: key))
        }

        return values
    }
}



//===----------------------------------------------------------------------===//
// MARK: - Observable Value
//===----------------------------------------------------------------------===//
public final class ObservableValue: ObservableObject, Hashable {

    /// Observation ``Context``.
    let context: Context

    public init(context: Context) {
        self.context = context
    }

    /// Call this method when value is about to change.
    public func valueWillChange() {
        objectWillChange.send()
    }

    /// `ObjectIdentifier` of self.
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }


    // MARK: Hashable

    public static func == (lhs: ObservableValue, rhs: ObservableValue) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
