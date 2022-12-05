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

    let storage = ObservationStorage()

    func subscribe<T: ObservableAtomicValue>(
        _ observableAtomicValue: T,
        for key: StorageKey
    ) {
        let poster = Signposter()
        let end = poster.addObservationStart(key)
        defer { end() }
        let observation = ObservableAtomicValue.WeakRef(observableAtomicValue)
        storage.add(observation, for: key)
    }

    func didChangeValue(for keys: Set<StorageKey>) {
        let poster = Signposter()
        let end = poster.popObservationsStart(keys)
        defer { end() }
        poster.logger.debug("Value changed for keys: \(keys.description)")

        let observers = Set(keys.flatMap { storage.pop(observationsOf: $0) })

        poster.logger.debug("Notified: \(observers.prettyPrint)")
        observers.forEach { observer in
            observer.value?.send()
        }

    }

    func didChangeValue(for key: StorageKey) {
        didChangeValue(for: Set([key]))
    }
}

public final class ObservableAtomicValue: ObservableObject, Hashable {

    public init() {}
    public func send() { objectWillChange.send() }

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
            ObjectIdentifier(lhs.value as AnyObject) == ObjectIdentifier(rhs.value as AnyObject)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self.value as AnyObject))
        }
    }
}

final class ObservationStorage {
    var storage: [StorageKey: Set<ObservableAtomicValue.WeakRef>] = [:]

    func add(_ observation: ObservableAtomicValue.WeakRef, for key: StorageKey) {
        var observationsOfKey = storage[key] ?? []
        observationsOfKey.insert(observation)
        storage[key] = observationsOfKey
    }

    func pop(observationsOf key: StorageKey) -> Set<ObservableAtomicValue.WeakRef> {
        let observations = storage[key] ?? []
        storage.removeValue(forKey: key)
        return observations
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

extension Set<ObservableAtomicValue.WeakRef> {
    var prettyPrint: String {
        return self
            .map { ObjectIdentifier($0.value as AnyObject) }
            .map {
                $0.debugDescription
                    .replacingOccurrences(of: "ObjectIdentifier", with: "")
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
            }.joined(separator: ", ")
    }
}
