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
/**
 PLACEHOLDER:
 Implementation in later releases.

 Idea: Provide the sync with the remote source e.g. via HTTP request.
 Requires the `ObservableAsyncValueWrapper` to accommodate the async nature.
 */
@propertyWrapper
@MainActor
public final class RemoteValue<Value>: ObservableValueStorageWrapper {
    public var wrappedValue: Value { storage.value }
    public var projectedValue: RemoteValue<Value> { self }
    public var storage: ValueStorage<Value>

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.storage = ValueStorage(initialValue: wrappedValue)
    }

    public init<Wrapper: ObservableValueStorageWrapper>(wrappedValue: Wrapper) where Wrapper.Value == Value {
        self.storage = wrappedValue.storage
    }
}
