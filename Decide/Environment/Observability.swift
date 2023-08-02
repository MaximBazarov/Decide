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
import Combine


/// Holds a week reference to actual observer, notifies only if object still exist.
final class Observer: Hashable {
    final class Notification {
        let notify: () -> Void

        init(notify: @escaping () -> Void) {
            self.notify = notify
        }
    }

    private var notification: Notification
    private var id: ObjectIdentifier

    @MainActor init(_ observer: ValueWillChangeNotification) {
        self.notification = Notification { [weak observer] in
            observer?.objectWillChange.send()
        }
        self.id = ObjectIdentifier(observer)
    }

    @MainActor init(_ observer: EnvironmentObservingObject) {
        self.notification = Notification { [weak observer] in
            observer?.environmentDidUpdate()
        }
        self.id = ObjectIdentifier(observer)
    }

    @MainActor func notify() {
        notification.notify()
    }

    static func == (lhs: Observer, rhs: Observer) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// ObservableObject for a value.
final class ValueWillChangeNotification: ObservableObject {}

@MainActor final class ObserverStorage {
    private var observers: Set<Observer> = []

    func subscribe(_ observer: Observer) {
        observers.insert(observer)
    }

    func popObservers() -> Set<Observer> {
        let result = observers
        observers = []
        return result
    }
}

