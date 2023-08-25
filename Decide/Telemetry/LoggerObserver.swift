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

final class OSLogTelemetryObserver: TelemetryObserver {

    static let subsystem = "State and Side-effects (Decide)"

    static let unsafeTracingEnabled: Bool = {
        guard let config: String = ProcessInfo
            .processInfo
            .environment["DECIDE_UNSAFE_TRACING_ENABLED"]
        else {
            return false
        }

        if let intValue = Int(config) {
            return intValue == 1 ? true : false
        }

        if config.replacingOccurrences(of: " ", with: "").lowercased() == "true" {
            return true
        }

        if config.replacingOccurrences(of: " ", with: "").lowercased() == "yes" {
            return true
        }

        return false
    }()

    func eventDidOccur<E>(_ event: E) where E : TelemetryEvent {
        let logger = Logger(subsystem: Self.subsystem, category: event.category)
        if Self.unsafeTracingEnabled {
            unsafeTrace(event: event, logger: logger)
        } else {
            trace(event: event, logger: logger)
        }

    }

    func trace<E>(event: E, logger: Logger) where E : TelemetryEvent {
        switch event.logLevel {
        case .debug:
            logger.debug("\(event.name): \(event.message(), privacy: .sensitive)\n context: \(event.context.debugDescription)")
        case .info:
            logger.info("\(event.message(), privacy: .sensitive)")
        case .error:
            logger.error("\(event.message(), privacy: .sensitive)")
        case .fault:
            logger.fault("\(event.message(), privacy: .sensitive)")
        default:
            logger.log("\(event.message(), privacy: .sensitive)")
        }
    }

    func unsafeTrace<E>(event: E, logger: Logger) where E : TelemetryEvent {
        switch event.logLevel {
        case .debug:
            logger.debug("\(event.name): \(event.message(), privacy: .sensitive)\n context: \(event.context.debugDescription)")
        case .info:
            logger.info("\(event.message(), privacy: .public)")
        case .error:
            logger.error("\(event.message(), privacy: .public)")
        case .fault:
            logger.fault("\(event.message(), privacy: .public)")
        default:
            logger.log("\(event.message(), privacy: .public)")
        }
    }
}


