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

import Decide

@MainActor public func WithEnvironment<T>(_ environment: ApplicationEnvironment, object: T) -> T {
    Mirror(reflecting: object).replaceEnvironment(with: environment)
    return object
}

private extension Mirror {
    @MainActor func replaceEnvironment(with newEnvironment: ApplicationEnvironment) {
        for var child in children {
            replaceEnvironment(on: &child, with: newEnvironment)
        }
    }

    @MainActor func replaceEnvironment(on child: inout Mirror.Child, with newEnvironment: ApplicationEnvironment) {
        if let obj = child.value as? DefaultEnvironment {
            obj.wrappedValue = newEnvironment
            return
        }

        let m = Mirror(reflecting: child.value)
        m.replaceEnvironment(with: newEnvironment)
    }
}
