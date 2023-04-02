//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package 
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


/// Keyed with ``StorageKey`` set weak references to `ObservableObjectPublisher`
@MainActor public final class ObservationSystem {

    var telemetry: Telemetry

    init(telemetry: Telemetry) {
        self.telemetry = telemetry
    }

    let storage = ObservationStorage()

    func subscribe(
        _ publisher: ObservableValue,
        for key: StorageKey
    ) {
        let endInterval = telemetry.beginInterval_addObservation(key)
        defer { endInterval() }

        storage.add(publisher, for: key)
    }

    func didChangeValue(for keys: Set<StorageKey>) {
        let end = telemetry.popObservationsStart(keys)
        defer { end() }

        let observers = Set(keys.flatMap {
            storage.pop(observationsOf: $0)
        })
        observers.forEach { observer in
            observer.valueWillChange()
        }
    }

    func didChangeValue(for key: StorageKey) {
        didChangeValue(for: Set([key]))
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Storage
//===----------------------------------------------------------------------===//

final class ObservationStorage {
    var storage: [StorageKey: Set<ObservableValue>] = [:]

    func add(_ observation: ObservableValue, for key: StorageKey) {
        var observationsOfKey = storage[key] ?? []
        observationsOfKey.insert(observation)
        storage[key] = observationsOfKey
    }

    func pop(observationsOf key: StorageKey) -> Set<ObservableValue> {
        let observations = storage[key] ?? []
        storage.removeValue(forKey: key)
        return observations
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//

extension Telemetry {

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

    nonisolated func beginInterval_addObservation(_ key: StorageKey) -> () -> Void {
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

extension Set<ObservableValue> {
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
