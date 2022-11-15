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
@MainActor @propertyWrapper public final class Observe<Value>: ObservableObject, DynamicProperty {
    public let objectWillChange = ObservableObjectPublisher()
    public var wrappedValue: Value {
        get {
            core.instance.subscribe(publisher: objectWillChange, for: key)
            return getValue(reader)
        }
    }

    @Injected(\.decisionCore) var core

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
@MainActor @propertyWrapper public final class Bind<Value>: ObservableObject, DynamicProperty {
    @Injected(\.decisionCore) var core

    public let objectWillChange = ObservableObjectPublisher()

    public var wrappedValue: Value {
        get { getValue(reader) }
        set { setValue(writer, newValue) }
    }

    var reader: StorageReader {
        core.instance.reader()
    }

    var writer: StorageWriter {
        core.instance.writer()
    }

    init(getValue: @escaping (StorageReader) -> Value, setValue: @escaping (StorageWriter, Value) -> Void) {
        self.getValue = getValue
        self.setValue = setValue
    }

    private let getValue: @MainActor (StorageReader) -> Value
    private let setValue: @MainActor (StorageWriter, Value) -> Void
}

extension Observe: Injectable {}

