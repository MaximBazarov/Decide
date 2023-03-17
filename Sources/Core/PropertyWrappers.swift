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

import Combine
import SwiftUI


//===----------------------------------------------------------------------===//
// MARK: - Make Decision
//===----------------------------------------------------------------------===//

@MainActor @propertyWrapper public struct MakeDecision: DynamicProperty {

    @Environment(\.decisionCore) var environmentCore
    private var injectedCore: DecisionCore?

    public init(core: DecisionCore? = nil) {
        self.injectedCore = core
    }

    public var wrappedValue: @MainActor (Decision) -> Void {
        get {
            let core = self.injectedCore ?? environmentCore
            return { decision in
                core.execute(decision)
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
    var observedValue = ObservableValue()

    @Environment(\.decisionCore) var core

    @MainActor public var wrappedValue: Value {
        get {
            core.observationSystem.subscribe(observedValue, for: key)
            let value = getValue(reader)
            return value
        }
    }

    private var reader: StorageReader {
        core.reader()
    }

    private let key: StorageKey
    private let getValue: @MainActor (StorageReader) -> Value

    init(key: StorageKey, getValue: @MainActor @escaping (StorageReader) -> Value) {
        self.getValue = getValue
        self.key = key
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Bind
//===----------------------------------------------------------------------===//

/// Provides an observed read/write access to the value of the atomic state type.
@MainActor @propertyWrapper public struct Bind<Value>: DynamicProperty {
    @ObservedObject var observedValue = ObservableValue()

    @Environment(\.decisionCore) var core

    public var wrappedValue: Value {
        get {
            core.observationSystem.subscribe(observedValue, for: key)
            return getValue(reader)
        }
        nonmutating set {
            setValue(writer, newValue)
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    var reader: StorageReader {
        core.reader()
    }

    var writer: StorageWriter {
        core.writer()
    }

    let key: StorageKey
    init(key: StorageKey, getValue: @escaping (StorageReader) -> Value, setValue: @escaping (StorageWriter, Value) -> Void) {
        self.getValue = getValue
        self.setValue = setValue
        self.key = key
    }

    private let getValue: @MainActor (StorageReader) -> Value
    private let setValue: @MainActor (StorageWriter, Value) -> Void
}


//===----------------------------------------------------------------------===//
// MARK: - Logging
//===----------------------------------------------------------------------===//
let propertyWrappersOperations: StaticString = "@ Observe/Bind"

extension Signposter {
    nonisolated func subscribed(_ key: StorageKey, context: Context) -> () -> Void {
        let state = signposter.beginInterval(
            propertyWrappersOperations,
            id: id,
            "+  \(key.debugDescription, privacy: .private(mask: .hash)) context: \(context.debugDescription)"
        )
        return { [signposter] in
            signposter.endInterval(propertyWrappersOperations, state)
        }
    }
}
