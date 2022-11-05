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

    @Injected(
        \.decide.storage,
         lifespan: .permanent,
         scope: .shared
    ) var storage

    public var wrappedValue: Value {
        get { getValue(StorageReader(storage: storage.instance)) }
    }    

    private let getValue: @MainActor (StorageReader) -> Value

    init(getValue: @MainActor @escaping (StorageReader) -> Value) {
        self.getValue = getValue
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Bind
//===----------------------------------------------------------------------===//

/// Provides an observed read/write access to the value of the atomic state type.
@MainActor @propertyWrapper public final class Bind<Value>: ObservableObject, DynamicProperty {
    @Injected(\.decide.storage, lifespan: .permanent, scope: .shared) var storage

    public let objectWillChange = ObservableObjectPublisher()

    public var wrappedValue: Value {
        get { getValue(StorageReader(storage: storage.instance)) }
        set { setValue(StorageWriter(storage: storage.instance), newValue) }
    }

    private let getValue: @MainActor (StorageReader) -> Value
    private let setValue: @MainActor (StorageWriter, Value) -> Void

    init(getValue: @escaping (StorageReader) -> Value, setValue: @escaping (StorageWriter, Value) -> Void) {
        self.getValue = getValue
        self.setValue = setValue
    }
}

extension Observe: Injectable {}
