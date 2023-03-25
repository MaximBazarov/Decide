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

import OSLog
import SwiftUI

final class Signposter {
    let id: OSSignpostID
    let signposter: OSSignposter
    let logger: Logger

    init() {
        self.signposter = OSSignposter(subsystem: "im.mks.decide.signpost", category: "Core")
        self.id = signposter.makeSignpostID()
        self.logger = Logger(subsystem: "im.mks.decide.log", category: "Core")
    }

    nonisolated func emitEvent(_ name: StaticString) {
        signposter.emitEvent(name, id: id)
    }

}

public protocol Telemetry {
    @MainActor var id: OSSignpostID { get }
    @MainActor var signposter: OSSignposter { get }
    @MainActor var logger: Logger { get }
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

@MainActor public final class OSLogTracing: Sendable, Telemetry {
    public var id: OSSignpostID
    public var signposter: OSSignposter
    public var logger: Logger

    /// Creates a new
    /// - Parameters:
    ///   - subsystem: name of the subsystem used for grouping logs, intervals and signposts under this name
    ///   - category: Category of the subsystem used to group further by category name.
    public init(subsystem: String, category: String) {
        self.signposter = OSSignposter(subsystem: "\(subsystem).signpost", category: category)
        self.id = signposter.makeSignpostID()
        self.logger = Logger(subsystem: "\(subsystem).log", category: "Core")
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Environment
//===----------------------------------------------------------------------===//


struct TelemetryEnvironmentKey: EnvironmentKey {
    @MainActor
    static var defaultValue: Telemetry? = nil
}

extension EnvironmentValues {
    var decideTelemetry: Telemetry? {
        get { self[TelemetryEnvironmentKey.self] }
        set { self[TelemetryEnvironmentKey.self] = newValue }
    }
}

struct TelemetryChannelsEnvironmentKey: EnvironmentKey {
    @MainActor
    static var defaultValue: Set<TelemetryLevel> = []
}

extension EnvironmentValues {

    /// Set of the log levels that should be traced.
    var decideTelemetryLevels: Set<TelemetryLevel> {
        get { self[TelemetryChannelsEnvironmentKey.self] }
        set { self[TelemetryChannelsEnvironmentKey.self] = newValue }
    }
}
