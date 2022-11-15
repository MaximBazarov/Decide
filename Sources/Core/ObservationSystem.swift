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

    var observations: [StorageKey: Set<WeakRefPublisher>] = [:]

    func subscribe(
        publisher: ObservableObjectPublisher,
        for key: StorageKey
    ) {
        let publisher = WeakRefPublisher(publisher)
        guard observations.keys.contains(key) else {
            observations[key] = Set([publisher])
            return
        }
        observations[key]?.insert(publisher)
    }

    func didChangeValue(for keys: Set<StorageKey>) {
        keys.forEach { key in
            guard let refs = observations[key]
            else { return }
            refs.forEach({ ref in
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
