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

import Foundation

@MainActor public protocol DependencySystem {
    func add(dependency: StorageKey, thatInvalidates key: StorageKey)
    func popDependencies(of key: StorageKey) -> Set<StorageKey>
}

@MainActor final class DependencyGraph: DependencySystem {

    var dependencies: [StorageKey: Set<StorageKey>] = [:]

    /// Makes `key`, depending on `dependency`
    /// - Parameters:
    ///   - dependency: the key on invalidating of which `key` will be invalidated.
    ///   - key: key to be invalidated together with `dependency`
    func add(dependency: StorageKey, thatInvalidates key: StorageKey) {
        guard dependencies.keys.contains(dependency)
        else {
            dependencies[dependency] = Set([key])
            return
        }
        dependencies[dependency]?.insert(key)
    }

    /// Recursively traverses the dependency graph removes and returns all the keys that depend on the given `key`.
    ///
    /// - Parameters:
    ///   - key: key for which return dependencies
    ///   - result: All the dependencies of the key, recursively.
    func popDependencies(of key: StorageKey) -> Set<StorageKey> {
        var result = Set<StorageKey>([key])
        var queue = Queue()
        pop(for: key, into: &result, queue: &queue)
        result.forEach {
            dependencies.removeValue(forKey: $0)
        }
        dependencies.removeValue(forKey: key)
        return result
    }


    private func pop(for key: StorageKey, into result: inout Set<StorageKey>, queue: inout Queue) {
        result.insert(key)

        guard let keyDependencies = dependencies[key]
        else { return }

        queue.enqueue(keyDependencies.filter { !result.contains($0) })

        while let next = queue.dequeue() {
            pop(for: next, into: &result, queue: &queue)
        }
    }

    final class Queue {
        private(set) var values: Set<   StorageKey> = .init()
        private(set) var count: UInt = 0

        func dequeue() -> StorageKey? {
            guard let value = values.popFirst()
            else { return nil }
            count -= 1
            return value
        }

        func enqueue(_ keys: any Collection<StorageKey>) {
            values.formUnion(keys)
            count = UInt(values.count)
        }
    }
}
