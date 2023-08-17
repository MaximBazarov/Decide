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

@MainActor protocol ValueContainerStorage {
    init()
}

/// ApplicationEnvironment stores instances of ``AtomicState`` and ``KeyedState`` and provides tools for mutations and asynchronous executions of side-effects.
@MainActor public final class ApplicationEnvironment {
    enum Key: Hashable {
        case atomic(ObjectIdentifier)
        case keyed(ObjectIdentifier, AnyHashable)
    }

    static let `default` = ApplicationEnvironment()

    var storage: [Key: Any] = [:]
    let telemetry: Telemetry = {
        guard let config = ProcessInfo
            .processInfo
            .environment["DECIDE_TRACER"]
        else {
            return Telemetry(observer: OSLogTelemetryObserver()) // .noTelemetry 
        }

        if config.replacingOccurrences(of: " ", with: "").lowercased() == "oslog" {
            return Telemetry(observer: OSLogTelemetryObserver())
        }

        // OSLog by default
        return Telemetry(observer: OSLogTelemetryObserver()) // .noTelemetry
    }()

    subscript<S: ValueContainerStorage>(_ key: Key) -> S {
        if let state = storage[key] as? S { return state }
        let newValue = S.init()
        storage[key] = newValue
        return newValue
    }

    public init() {}
}

/// An object managed by environment
/// - Instantiated and held by ``ApplicationEnvironment``.
/// - `environment` value is set to the ``ApplicationEnvironment`` it is executed in.
///
public protocol EnvironmentManagedObject: AnyObject {
    @MainActor var environment: ApplicationEnvironment { get set }
}

