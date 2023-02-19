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

import Inject
import Combine
import SwiftUI

//===----------------------------------------------------------------------===//
// MARK: - Observe
//===----------------------------------------------------------------------===//

/// Provides an observed read-only access to the value of the atomic state type.
@MainActor @propertyWrapper public struct Observe<Value>: DynamicProperty {
    @ObservedObject public private(set)
    var observedValue = ObservableValue()

    @Injected(\.decisionCore, lifespan: .permanent, scope: .shared) public var core

    @MainActor public var wrappedValue: Value {
        get {
            core.instance.observationSystem.subscribe(observedValue, for: key)
            let value = getValue(reader)
            return value
        }
    }

    private var reader: StorageReader {
        core.instance.reader()
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
    @Injected(\.decisionCore, lifespan: .permanent, scope: .shared) var core

    public var wrappedValue: Value {
        get {
            core.instance.observationSystem.subscribe(observedValue, for: key)
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
        core.instance.reader()
    }

    var writer: StorageWriter {
        core.instance.writer()
    }

    let key: StorageKey
    init(key: StorageKey, getValue: @escaping (StorageReader) -> Value, setValue: @escaping (StorageWriter, Value) -> Void) {
        self.getValue = getValue
        self.setValue = setValue
        self.key = key
    }

    private let getValue: @MainActor (StorageReader) -> Value
    private let setValue: @MainActor (StorageWriter, Value) -> Void

    nonisolated public func update() {
        print("SwiftUI: dynamic property update for  \(key)")
    }
}



extension Observe: Injectable {}


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
