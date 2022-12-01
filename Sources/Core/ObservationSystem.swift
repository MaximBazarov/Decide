//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import Combine
import Inject

/// Keyed with ``StorageKey`` set weak references to `ObservableObjectPublisher`
@MainActor public final class ObservationSystem {

    var observations: [StorageKey: Set<ObservableAtomicValue.WeakRef>] = [:]

    func subscribe<T: ObservableAtomicValue>(
        _ observableAtomicValue: T,
        for key: StorageKey
    ) {
        let poster = Signposter()
        let end = poster.addObservationStart(key)
        defer { end() }
        let observation = ObservableAtomicValue.WeakRef(observableAtomicValue)
        guard observations.keys.contains(key) else {
            observations[key] = Set([observation])
            return
        }
        observations[key]?.insert(observation)
    }

    func didChangeValue(for keys: Set<StorageKey>) {
        let poster = Signposter()
        let end = poster.popObservationsStart(keys)
        defer { end() }

        let observers = Set<ObservableAtomicValue>(keys.flatMap { key in
            guard let refs = observations[key]
            else { return [ObservableAtomicValue]() }
            return refs.compactMap{ $0.value }
        })

        observers.forEach { observer in
            observer.send()
        }

        keys.forEach{ observations.removeValue(forKey: $0) }
    }

    func didChangeValue(for key: StorageKey) {
        didChangeValue(for: Set([key]))
    }
}

public final class ObservableAtomicValue: ObservableObject, Hashable {

    public init() {}
    public func send() {
        objectWillChange.send()
        print("update sent")
    }

    public static func == (lhs: ObservableAtomicValue, rhs: ObservableAtomicValue) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    final class WeakRef: Hashable {
        weak var value: ObservableAtomicValue?
        init(_ value: ObservableAtomicValue) {
            self.value = value
        }

        static func == (lhs: WeakRef, rhs: WeakRef) -> Bool {
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//

extension Signposter {
    nonisolated func popObservationsStart(_ keys: Set<StorageKey>) -> () -> Void {
        let name: StaticString = "Observers: pop"
        let state = signposter.beginInterval(
            name,
            id: id,
            "keys: \(keys.map{ $0.debugDescription }, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }

    nonisolated func addObservationStart(_ key: StorageKey) -> () -> Void {
        let name: StaticString = "Observers: add"
        let state = signposter.beginInterval(
            name,
            id: id,
            "key: \(key.debugDescription, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }
}
