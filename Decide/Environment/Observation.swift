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

class ObservationSystem {
    var storage: Set<ObservableValue> = []

    func subscribe(_ observation: ObservableValue) {
        storage.insert(observation)
    }

    func valueDidChange() {
        let observers = storage
        storage = []
        Task { await MainActor.run {
            observers.forEach { observer in
                observer.objectWillChange.send()
            }
        }}
    }
}

/// ObservableObject for a value.
final class ObservableValue: ObservableObject, Hashable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    public static func == (lhs: ObservableValue, rhs: ObservableValue) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
