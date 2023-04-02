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

//===----------------------------------------------------------------------===//
// MARK: - Bind
//===----------------------------------------------------------------------===//

/// Provides an observed read/write access to the value of the atomic state type.
@MainActor @propertyWrapper public struct Bind<Value>: DynamicProperty {
    @ObservedObject var observedValue: ObservableValue

    @Environment(\.decisionCore) var core
    private let context: Context

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
        core.reader(context: context)
    }

    var writer: StorageWriter {
        core.writer(context: context)
    }

    let key: StorageKey
    init(
        key: StorageKey,
        context: Context,
        getValue: @escaping (StorageReader) -> Value,
        setValue: @escaping (StorageWriter, Value) -> Void
    ) {
        self.getValue = getValue
        self.setValue = setValue
        self.key = key
        self.context = context
        self._observedValue = ObservedObject(
            initialValue: ObservableValue(context: context)
        )
    }

    private let getValue: @MainActor (StorageReader) -> Value
    private let setValue: @MainActor (StorageWriter, Value) -> Void
}
