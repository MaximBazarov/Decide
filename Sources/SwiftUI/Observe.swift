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

import Combine
import SwiftUI


//===----------------------------------------------------------------------===//
// MARK: - Make Decision Property Wrapper
//===----------------------------------------------------------------------===//

/// A property wrapper that provides a function to execute a `Decision`
/// in the context of a ``Storage``.
///
/// This property wrapper can be used in a SwiftUI view to access the
/// functionality of the ``Storage``.
/// When an action that requires a decision is triggered in the view,
/// the wrapped function can be called
/// with the appropriate decision,
/// which is then executed by the ``Storage``.
///
/// The `MakeDecision` property wrapper uses the ``Storage``
/// provided by the environment.
///
/// Usage:
/// ```
/// struct MyView: View {
///     @MakeDecision var makeDecision
///
///     var body: some View {
///         Button("Button") {
///             makeDecision(
///                 UpdateTitle(title:"Example")
///             )
///         }
///     }
/// }
/// ```
///
/// However, you can also inject a custom ``Storage`` instance during initialization.
///
/// ```
/// // Inject the custom decision core into MyView using the environment
/// struct ContentView: View {
///     var body: some View {
///         MyView()
///             .decisionCore(injectedCore)
///     }
/// }
/// ```
///
/// - Note: This property wrapper is marked with `@MainActor` to ensure that the wrapped function is called
///   on the main actor, which is required for updating the UI in SwiftUI.
@MainActor @propertyWrapper public struct MakeDecision: DynamicProperty {

    /// The `Storage` instance provided through the environment.
    @Environment(\.decisionCore) var environmentCore
    let context: Context

    /// The `Storage` instance provided through dependency injection.
    private var injectedCore: Storage?

    /// Creates a `MakeDecision` property wrapper with an optional `Storage` instance to use for dependency injection.
    /// - Parameter core: The `Storage` instance to use for dependency injection.
    public init(
        core: Storage? = nil,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        self.injectedCore = core
        self.context = Context(
            className: function,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
    }

    /// The wrapped function that executes the given `Decision` by calling the appropriate `Storage` instance.

    public var wrappedValue: @MainActor (Decision) -> Void {
        get {
            let core = self.injectedCore ?? environmentCore
            return { decision in
                core.execute(decision, context: context)
            }
        }
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

/// Provides an observed read-only access to the value of the atomic state type.
@MainActor @propertyWrapper public struct Observe<Value>: DynamicProperty {
    @ObservedObject public private(set)
    var observedValue: ObservableValue

    @Environment(\.decisionCore) var core
    private let context: Context

    @MainActor public var wrappedValue: Value {
        get {
            core.observationSystem.subscribe(observedValue, for: key)
            let value = getValue(reader)
            return value
        }
    }

    private var reader: StorageReader {
        core.reader(context: context)
    }

    private let key: StorageKey
    private let getValue: @MainActor (StorageReader) -> Value

    init(key: StorageKey, context: Context, getValue: @MainActor @escaping (StorageReader) -> Value) {
        self.getValue = getValue
        self.key = key
        self.context = context
        self._observedValue = ObservedObject(initialValue: ObservableValue(context: context))
    }
}



//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//
let propertyWrappersOperations: StaticString = "@ Observe/Bind"

extension Telemetry {
    nonisolated func subscribed(_ key: StorageKey, context: Context) -> () -> Void {
        let state = signposter.beginInterval(
            propertyWrappersOperations,
            id: id,
            """
            key: \(key.debugDescription, privacy: .private(mask: .hash))
            context: \(context.debugDescription)
            """
        )
        return { [signposter] in
            signposter.endInterval(propertyWrappersOperations, state)
        }
    }
}
