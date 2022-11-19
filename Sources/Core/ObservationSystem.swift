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
@MainActor final class ObservationSystem {

    var observations: [StorageKey: Set<WeakRefPublisher>] = [:]

    func subscribe(
        publisher: ObservableObjectPublisher,
        for key: StorageKey
    ) {
        let poster = Signposter()
        let end = poster.addObservationStart(key)
        defer { end() }
        let publisher = WeakRefPublisher(publisher)
        guard observations.keys.contains(key) else {
            observations[key] = Set([publisher])
            return
        }
        observations[key]?.insert(publisher)
    }

    func didChangeValue(for keys: Set<StorageKey>) {
        let poster = Signposter()
        let end = poster.popObservationsStart(keys)
        defer { end() }
        keys.forEach { key in
            poster.emitEvent("K")
            guard let refs = observations[key]
            else {
                return
            }
            refs.forEach({ ref in
                poster.emitEvent("r")
                ref.value?.send()
            })
        }

        keys.forEach{ observations.removeValue(forKey: $0) }
    }
}

final class WeakRefPublisher: Hashable {
    weak var value: ObservableObjectPublisher?

    init(_ value: ObservableObjectPublisher) {
        self.value = value
    }

    static func == (lhs: WeakRefPublisher, rhs: WeakRefPublisher) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
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
