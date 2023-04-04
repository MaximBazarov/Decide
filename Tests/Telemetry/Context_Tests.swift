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
import XCTest
import Decide

final class ContextTests: XCTestCase {
    func testInit() {
        let context1 = Context(
            symbol: String.self,
            file: "file1.swift",
            fileID: "file1ID",
            line: 10,
            column: 5,
            function: "function1"
        )
        XCTAssertEqual(context1.symbol, "Swift.String")
        XCTAssertEqual(context1.file, "file1.swift")
        XCTAssertEqual(context1.fileID, "file1ID")
        XCTAssertEqual(context1.line, 10)
        XCTAssertEqual(context1.column, 5)
        XCTAssertEqual(context1.function, "function1")
    }

    func testHere() {
        let context2 = Context.here(
            as: Int.self,
            file: "file2.swift",
            fileID: "file2ID",
            line: 20,
            column: 10,
            function: "function2"
        )
        XCTAssertEqual(context2.symbol, "Swift.Int")
        XCTAssertEqual(context2.file, "file2.swift")
        XCTAssertEqual(context2.fileID, "file2ID")
        XCTAssertEqual(context2.line, 20)
        XCTAssertEqual(context2.column, 10)
        XCTAssertEqual(context2.function, "function2")
    }

    func testDebugDescription() {
        let context3 = Context(
            symbol: Bool.self,
            file: "file3.swift",
            fileID: "file3ID",
            line: 30,
            column: 15,
            function: "function3"
        )
        XCTAssertEqual(context3.debugDescription, "Swift.Bool (file3.swift:30:15)")
    }
}
