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

import XCTest
@testable import Decide

@MainActor final class DependencySystemTests: XCTestCase {

    func test_Graph_pop_mustReturn_allDependencies() {
        let sut = DependencyGraph()
        sut.mock_ABCDEF_ABCA_cycle()

        let result = sut.popDependencies(of: C.key)

        let expected = [
            A.key, B.key, C.key, D.key, E.key, F.key
        ]

        AssertStorageKeySet(result, isExactly: expected)
    }

    func test_Graph_ABCDEF_pop_F_mustReturn_no_dependencies() {
        let sut = DependencyGraph()
        sut.mock_ABCDEF_ABCA_cycle()

        let result = sut.popDependencies(of: F.key)

        let expected = [F.key]

        AssertStorageKeySet(result, isExactly: expected)
    }

}

func AssertStorageKeySet(_ actual: Set<StorageKey>, isExactly expected: [StorageKey], _ file: StaticString = #file, _ line: UInt = #line) {
    let expected = Set(expected)
    var unexpected = Set<StorageKey>()
    actual.forEach { key in
        if !expected.contains(key) { unexpected.insert(key) }
    }
    var missing = Set<StorageKey>()
    expected.forEach { key in
        if !actual.contains(key) { missing.insert(key) }
    }

    enum Status {
        case missing
        case unexpected

        var asString: String {
            switch self {
            case .missing:
                return "is missing in actual value"
            case .unexpected:
                return "is not in expected value, must not be in actual value"
            }
        }
    }
    let diff = Array(actual.union(expected))
        .reduce(into: [StorageKey: Status]()) { partialResult, key in
            switch (missing.contains(key), unexpected.contains(key)) {
            case (true, _):
                partialResult[key] = .missing
            case (_, true):
                partialResult[key] = .unexpected
            default:
                break
            }
        }

    if diff.isEmpty { return }

    var message = "\n"
    diff
        .sorted(by: { lhs, rhs in
            lhs.key.debugDescription < rhs.key.debugDescription
        })
        .forEach({ key, status in
            message += "\(key): \(status.asString)\n"
        })

    XCTFail("Doesn't match: \(message)", file: file, line: line)
    return
}

//===----------------------------------------------------------------------===//
// MARK: - Mock States
//===----------------------------------------------------------------------===//

struct A: AtomicState { static func defaultValue() -> Int { 0 }}
struct B: AtomicState { static func defaultValue() -> Int { 0 }}
struct C: AtomicState { static func defaultValue() -> Int { 0 }}
struct D: AtomicState { static func defaultValue() -> Int { 0 }}
struct E: AtomicState { static func defaultValue() -> Int { 0 }}
struct F: AtomicState { static func defaultValue() -> Int { 0 }}

extension DependencyGraph {

    /// Graph with a cycle mock:
    /// ```
    ///   ┌──────────────────┐
    /// ┌─▼─┐    ┌───┐     ┌─┴─┐
    /// │ A ├────► B ├─────► C │
    /// └─┬─┘    └─┬─┘     └─┬─┘
    /// ┌─▼─┐    ┌─▼─┐     ┌─▼─┐
    /// │ D ├────► E ├─────► F │
    /// └───┘    └───┘     └───┘
    /// ```
    func mock_ABCDEF_ABCA_cycle() {
        add(dependency: A.key, thatInvalidates: B.key)
        add(dependency: A.key, thatInvalidates: D.key)

        add(dependency: B.key, thatInvalidates: C.key)
        add(dependency: B.key, thatInvalidates: E.key)

        add(dependency: C.key, thatInvalidates: F.key)
        add(dependency: C.key, thatInvalidates: A.key)

        add(dependency: D.key, thatInvalidates: E.key)

        add(dependency: E.key, thatInvalidates: F.key)
    }
}
