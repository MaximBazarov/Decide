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

@MainActor @propertyWrapper final class Observe<Value> {
    var wrappedValue: Value {
        get { getValue() }
    }

    private var getValue: () -> Value
    private var storage: Storage = DependenciesAutoGraphStorage()

    init(
        key: StorageKey,
        onBehalf ownerKey: StorageKey,
        defaultValue: @escaping () -> Value
    ) {
        getValue = { [storage] in
            storage.getValue(
                for: key,
                onBehalf: ownerKey,
                defaultValue: defaultValue
            )
        }
    }
}
