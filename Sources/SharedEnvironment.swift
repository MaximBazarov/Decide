// SharedEnvironment.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

import Foundation
import OSLog

extension StaticString {
    var decideSubsystem: StaticString { "lib.decide" }
    var decideStateIO: StaticString { "State I/O" }
}

/// Shared environment among all components of the system.
/// Unless overridden in component, ``SharedEnvironment/default`` is used.
/// Works as the SwiftUI environment but shared with non-SwiftUI context.
public final class SharedEnvironment {
    typealias StorageReference = ObjectIdentifier

    @MainActor private var storage: [StorageReference: any StorageNamespace] = [:]

    @MainActor func get<Namespace: StorageNamespace>(_ namespace: Namespace.Type) -> Namespace {
        let key = StorageReference(namespace)
        if let value = storage[key] {
            return unsafeDowncast(value, to: Namespace.self)
        }

        let value = namespace.init()
        storage[key] = value
        return value
    }
}

public extension SharedEnvironment {
    static let `default` = SharedEnvironment()
}

// MARK: - SwiftUI Environment

#if canImport(SwiftUI)
    import SwiftUI

    private struct SharedEnvironment_SwiftUIEnvironmentKey: EnvironmentKey {
        static let defaultValue: SharedEnvironment = .default
    }

    public extension EnvironmentValues {
        var sharedEnvironment: SharedEnvironment {
            get { self[SharedEnvironment_SwiftUIEnvironmentKey.self] }
            set { self[SharedEnvironment_SwiftUIEnvironmentKey.self] = newValue }
        }
    }

    public extension View {
        /// Overrides ``SharedEnvironment`` in the SwiftUI view `Environment`.
        func sharedEnvironment(_ value: SharedEnvironment) -> some View {
            environment(\.sharedEnvironment, value)
        }
    }
#endif
