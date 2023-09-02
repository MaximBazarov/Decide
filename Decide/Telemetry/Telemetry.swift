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

final class Telemetry {

    /// Minimum log level to log.
    /// [Choose the Appropriate Log Level for Each Message](https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code#3665947)
    var logLevel: OSLogType = .default

    let observer: TelemetryObserver

    init(observer: TelemetryObserver) {
        self.observer = observer
    }

    func log<Event: TelemetryEvent>(event: Event) {
        guard event.logLevel.rawValue >= self.logLevel.rawValue
        else { return }
        observer.eventDidOccur(event)
    }
}

final class DoNotObserve: TelemetryObserver {
    func eventDidOccur<Event>(_ event: Event) where Event : TelemetryEvent {}
}
extension Telemetry {
    static let noTelemetry = Telemetry(observer: DoNotObserve())
}

/// [Choose the Appropriate Log Level for Each Message](https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code#3665947)
protocol TelemetryEvent {
    var category: String { get }
    var name: String { get }
    var context: Context { get }
    var logLevel: OSLogType { get }

    func message() -> String
}

protocol TelemetryObserver {
    /// Called every time an event with debug level
    /// equal or greater than current occur.
    func eventDidOccur<Event: TelemetryEvent>(_ event: Event)
}

