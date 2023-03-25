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
import SwiftUI

//===----------------------------------------------------------------------===//
// MARK: - Dependency System Protocol
//===----------------------------------------------------------------------===//

@MainActor protocol DependencySystem {
    func add(dependency: StorageKey, thatInvalidates key: StorageKey)
    func popDependencies(of key: StorageKey) -> Set<StorageKey>
}


//===----------------------------------------------------------------------===//
// MARK: - Dependency Graph (Default)
//===----------------------------------------------------------------------===//

extension DependencyGraph {
    /// Makes `key`, depending on `dependency`
    /// - Parameters:
    ///   - dependency: the key on invalidating of which `key` will be invalidated.
    ///   - key: key to be invalidated together with `dependency`
    func add(dependency: StorageKey, thatInvalidates key: StorageKey) {
        let end = telemetry?.addDependenciesStart(key)
        defer {
            telemetry?.logger.trace("+ \(dependency.debugDescription, privacy: .private(mask: .hash)) that invalidates \(key.debugDescription)")
            end?()
        }

        guard dependencies.keys.contains(dependency)
        else {
            dependencies[dependency] = Set([key])
            return
        }

        dependencies[dependency]?.insert(key)
    }

    /// Recursively traverses (BFS) the dependency graph removes and returns all the keys that depend on the given `key`.
    ///
    /// - Parameters:
    ///   - key: key for which return dependencies
    ///   - result: All the dependencies of the key, recursively.
    func popDependencies(of key: StorageKey) -> Set<StorageKey> {
        let end = telemetry?.popDependenciesStart(key)
        defer { end?() }

        var result = Set<StorageKey>([key])
        var queue = Queue()
        pop(for: key, into: &result, queue: &queue)
        result.forEach {
            dependencies.removeValue(forKey: $0)
        }
        dependencies.removeValue(forKey: key)
        telemetry?.logger.trace("pop: \(result.map{ $0.debugDescription }.joined(separator: "\n"), privacy: .private(mask: .hash)) that invalidates \(key.debugDescription)")
        return result
    }
}

@MainActor final class DependencyGraph: DependencySystem {
    var telemetry: Telemetry?
    var telemetryLevels: Set<TelemetryLevel> = []

    var dependencies: [StorageKey: Set<StorageKey>] = [:]

    private func pop(for key: StorageKey, into result: inout Set<StorageKey>, queue: inout Queue) {
        result.insert(key)

        guard let keyDependencies = dependencies[key]
        else { return }

        queue.enqueue(keyDependencies.filter { 
            !result.contains($0) 
        })

        while let next = queue.dequeue() {
            pop(for: next, into: &result, queue: &queue)
        }
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Queue
//===----------------------------------------------------------------------===//

private extension DependencyGraph {
    final class Queue {
        private(set) var values: Set<StorageKey> = .init()
        private(set) var count: UInt = 0

        func dequeue() -> StorageKey? {
            guard let value = values.popFirst()
            else { return nil }
            count -= 1
            return value
        }

        func enqueue(_ keys: Set<StorageKey>) {
            values.formUnion(keys)
            count = UInt(values.count)
        }
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//


extension Telemetry {

    static var dependencyOperations: StaticString { "Dependency" }

    @MainActor
    func popDependenciesStart(_ key: StorageKey) -> () -> Void {
        let state = signposter.beginInterval(
            Self.dependencyOperations,
            id: self.id,
            "pop: \(key.debugDescription, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(Self.dependencyOperations, state)
        }
    }

    @MainActor
    func addDependenciesStart(_ key: StorageKey) -> () -> Void {
        let state = signposter.beginInterval(
            Self.dependencyOperations,
            id: self.id,
            "+ Add: \(key.debugDescription, privacy: .private(mask: .hash))"
        )
        return { [signposter] in
            signposter.endInterval(Self.dependencyOperations, state)
        }
    }
}
