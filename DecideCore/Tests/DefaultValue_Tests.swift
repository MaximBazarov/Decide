// DefaultValue_Tests.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

@testable import Decide
import XCTest

final class DefaultValueTests: XCTestCase {
    final class TestState: StorageNamespace {
        @DefaultValue var intValue = 7
    }

    func test_() async throws {}
}
