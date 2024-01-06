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

/// Holds a week reference to actual observer, notifies only if object still exist.
public final class Observer: Hashable {
    private(set) var notify: () -> Void
    private var id: ObjectIdentifier

    @MainActor init<O: AnyObject>(_ observer: O, notify: @escaping () -> Void) {
        self.notify = notify
        self.id = ObjectIdentifier(observer)
    }

    public static func == (lhs: Observer, rhs: Observer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

///// ObservableObject for a value.
//final class ObservedObjectWillChangeNotification: ObservableObject {}

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

    func sendAll() {
        let observers = popObservers()
        observers.forEach { $0.notify() }
    }
}

