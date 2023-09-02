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

import OSLog

final class UnstructuredMutation<Value>: TelemetryEvent {
    let category: String = "Unstructured State Mutation"
    let name: String = "Property updated:"
    let logLevel: OSLogType = .debug
    let context: Decide.Context

    let keyPath: String
    let value: Value

    init(context: Decide.Context, keyPath: String, value: Value) {
        self.keyPath = keyPath
        self.context = context
        self.value = value
    }

    func message() -> String {
        "\(keyPath) -> \(String(reflecting: value))"
    }
}
