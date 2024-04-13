// SharedEnvironment_Tests.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

@testable import Decide
import XCTest

final class SharedEnvironmentTests: XCTestCase {
    final class TestState: StorageNamespace {}
    final class TestAditionalState: StorageNamespace {}

    func test_ProvidesTheSameInstance_ForNameSpace() async throws {
        let env = SharedEnvironment()
        let ns1 = await env.get(TestState.self)
        let ns2 = await env.get(TestState.self)
        XCTAssert(ns1 === ns2, "Must be the same instance")
    }

    func test_ProvidesDifferentInstances_ForDifferentNameSpaces() async throws {
        let env = SharedEnvironment()
        let ns1 = await env.get(TestState.self)
        let ns2 = await env.get(TestAditionalState.self)
        print(ns1)
        print(ns2)
        XCTAssert(ns1 !== ns2, "Must be different instances")
    }

    func test_ProvidesDifferentInstances_ForDifferentEnvironments() async throws {
        let env1 = SharedEnvironment()
        let env2 = SharedEnvironment()
        let ns1 = await env1.get(TestState.self)
        let ns2 = await env2.get(TestState.self)
        XCTAssert(ns1 !== ns2, "Must be different instances")
    }
}
