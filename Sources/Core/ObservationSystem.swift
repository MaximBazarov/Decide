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

    func subscribe(
        observationID: AnyHashable,
        send: @escaping () -> Void,
        for key: StorageKey
    ) {
        let poster = Signposter()
        let end = poster.addObservationStart(key)
        poster.logger.debug("Observe \(key.debugDescription)")
        defer { end() }
        let observation = Observation(id: observationID, send)
        storage.add(observation, for: key)
    }

    func didChangeValue(for keys: Set<StorageKey>) {
        let poster = Signposter()
        let end = poster.popObservationsStart(keys)
        poster.logger.debug("Value changed for keys: \(keys.description)")
        defer {
            end()
        }
        let observers = Set(keys.flatMap { storage.pop(observationsOf: $0) })

        poster.logger.trace("Notified observers of  \(observers.count)")
        observers.forEach { observer in
            observer.send()
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

        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }    
}

final class ObservationStorage {
    var storage: [StorageKey: Set<Observation>] = [:]

    func add(_ observation: Observation, for key: StorageKey) {
        var observationsOfKey = storage[key] ?? []
        observationsOfKey.insert(observation)
        storage[key] = observationsOfKey
    }

    func pop(observationsOf key: StorageKey) -> Set<Observation> {
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
        let name: StaticString = "Observers"
        let state = signposter.beginInterval(
            name,
            id: id,
            "Pop keys: \(keys.map{ $0.debugDescription }, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }

    nonisolated func addObservationStart(_ key: StorageKey) -> () -> Void {
        let name: StaticString = "Observers"
        let state = signposter.beginInterval(
            name,
            id: id,
            "Add key: \(key.debugDescription, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(name, state)
        }
    }
}

extension Set<Observation> {
    var prettyPrint: String {
        return self
            .map { $0.id }
            .map {
                $0.debugDescription
                    .replacingOccurrences(of: "ObjectIdentifier", with: "")
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
            }.joined(separator: ", ")
    }
}
