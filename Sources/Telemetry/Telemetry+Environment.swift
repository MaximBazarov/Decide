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

import SwiftUI

struct TelemetryEnvironmentKey: EnvironmentKey {
    static var defaultValue: Telemetry? = nil
}

extension EnvironmentValues {
    var decideTelemetry: Telemetry? {
        get { self[TelemetryEnvironmentKey.self] }
        set { self[TelemetryEnvironmentKey.self] = newValue }
    }
}

struct TelemetryChannelsEnvironmentKey: EnvironmentKey {
    static var defaultValue: Set<TelemetryLevel> = []
}

extension EnvironmentValues {

    /// Set of the log levels that should be traced.
    var decideTelemetryLevels: Set<TelemetryLevel> {
        get { self[TelemetryChannelsEnvironmentKey.self] }
        set { self[TelemetryChannelsEnvironmentKey.self] = newValue }
    }
}
