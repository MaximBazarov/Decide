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

import OSLog
import SwiftUI

final actor Telemetry {
    let id: OSSignpostID
    let signposter: OSSignposter
    let logger: Logger

    /// Creates a new
    /// - Parameters:
    ///   - subsystem: name of the subsystem used for grouping logs, intervals and signposts under this name
    ///   - category: Category of the subsystem used to group further by category name.
    init(subsystem: String, category: String) {
        self.signposter = OSSignposter(subsystem: "\(subsystem).signpost", category: category)
        self.id = signposter.makeSignpostID()
        self.logger = Logger(subsystem: "\(subsystem).log", category: "Core")
    }

    func emitEvent(_ name: StaticString) {
        signposter.emitEvent(name, id: id)
    }
}

public enum TelemetryLevel: Hashable {
    case logs
    case storage
    case dependencies
    case accessors
    case observation
    case decisions
    case effects
}
