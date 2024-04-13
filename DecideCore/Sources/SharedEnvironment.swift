// SharedEnvironment.swift
// Copyright © 2024 Maxim Bazarov and Decide Authors.
// Licensed under MIT. SPDX-License-Identifier: MIT

import Foundation
import OSLog

/// Public extension of `SharedEnvironment`.
/// This extension provides a static `default` instance of `SharedEnvironment`.
/// This `default` instance is shared across all components and modules in the system.
/// It serves as the default environment unless a specific component overrides it locally.
public extension SharedEnvironment {
    /// Default environment shared across all components and modules, unless overriden locally for the component.
    static let `default` = SharedEnvironment()
}

/// `SharedEnvironment` is a shared context used across all system components and modules.
/// It functions similarly to the SwiftUI environment, but is also accessible in non-SwiftUI contexts.
/// By default, unless explicitly overridden in a component, the `SharedEnvironment/default` is utilized.
public final class SharedEnvironment {
    typealias StorageReference = ObjectIdentifier

    @MainActor private var storage: [StorageReference: any StorageNamespace] = [:]

    /// This function retrieves a value from the shared environment storage.
    /// It is marked with `@MainActor` to ensure that it's executed on the main thread.
    ///
    /// - Parameter namespace: The type of the storage namespace instance of which to retrieve.
    /// - Returns: The instance of the ``Namespace`` associated with its type.
    ///
    /// If a value for the provided namespace type already exists in the storage, it is returned.
    /// If not, a new instance of the namespace type is created, stored, and then returned.
    ///
    /// The function uses `unsafeDowncast` to cast the stored value to the specified namespace type.
    /// This is safe as the function ensures that values stored in the storage are always of the type associated with their namespace.
    @MainActor public func get<Namespace: StorageNamespace>(_ namespace: Namespace.Type) -> Namespace {
        let key = StorageReference(namespace)
        if let value = storage[key] {
            return unsafeDowncast(value, to: Namespace.self)
        }

        let value = namespace.init()
        storage[key] = value
        return value
    }
}

// MARK: - OSLog

extension StaticString {
    var decideSubsystem: StaticString { "lib.decide" }
    var decideStateIO: StaticString { "State I/O" }
}
