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
import OSLog


/// Telemetry configuration for Decide systems.
///
/// ``Decide`` uses OSLog with Swift's new functionality to send logs, traces,
/// signposts, and other events in a secure and performant way.
/// This configuration defines which events must be sent.
/// By default, no events are sent.
///
/// Setting the ``Level`` of the tracing events will enable or silence
/// events depending on the desired level of verbosity.
public enum Telemetry {
    static let subsystem = "Decide"

    enum Category {
        static let storage = "Value Storage"
        static let decisions = "Decisions"
        static let effects = "Effects"
    }

    /// Set **DECIDE_TELEMETRY_LEVEL** process environment variable to
    /// the desired value from the list.
    /// Each level represents the extent to which tracing events are emitted,
    /// with 0 resulting in complete silence.
    ///
    /// Example:
    /// ```sh
    /// env DECIDE_TELEMETRY_LEVEL=8 swift test
    /// ```
    ///
    /// This command runs the tests with full telemetry enabled, ensuring that all tracing and
    /// logging events are sent by ``Decide``.
    ///
    /// You can also set this variable in Xcode by adding it
    /// into the arguments in the run/test configuration.
    public enum Level: Int {
        /// No telemetry
        case none = 0

        /// Decision-related events
        case decisions = 2

        /// Events related to decisions and effects
        case effects = 4

        /// Full log, including all tracing and logging events
        case debug = 8
    }


    static let level: Level = {
        return Level(ProcessInfo
            .processInfo
            .environment["DECIDE_TELEMETRY_LEVEL"]
        )
    }()
}

extension Telemetry.Level {
    init(_ level: String?) {
        guard
            let level = level,
            let levelInt = Int(level)
        else {
            self = .none
            return
        }

        self = .init(rawValue: levelInt) ?? .none
    }
}




