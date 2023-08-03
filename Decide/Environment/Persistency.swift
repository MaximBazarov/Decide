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

@MainActor public class PersistencyStrategy<Value> {
    private(set) var valueContainer: ValueContainer<Value>

    public init(valueContainer: ValueContainer<Value>) {
        self.valueContainer = valueContainer
    }

    func valueDidChange() {
        fatalError("Not implemented")
    }
}
