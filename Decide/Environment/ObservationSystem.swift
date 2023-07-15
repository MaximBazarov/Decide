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
    var subscriberStorage: Set<WeakEnvironmentObservingObject> = []

    func subscribe(_ object: EnvironmentObservingObject) {
        let weakObject = WeakEnvironmentObservingObject(object)
        guard subscriberStorage.contains(weakObject) else {
            subscriberStorage.insert(weakObject)
            return
        }
        subscriberStorage.insert(weakObject)
    }

    func subscribe(_ observation: ObservableValue) {
        storage.insert(observation)
    }

    func valueDidChange() {
        let valueObservers = storage
        storage = []
        let defaultSubscribers = subscriberStorage
        subscriberStorage = []
        Task { await MainActor.run {
            valueObservers.forEach { observer in
                observer.objectWillChange.send()
            }
            defaultSubscribers.forEach({ subscriber in
                subscriber.value?.environmentDidUpdate()
            })
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
