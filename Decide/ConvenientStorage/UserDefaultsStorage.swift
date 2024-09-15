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

@MainActor public final class UserDefaultsStorage<Value>: ValueStorage<Value> {

    public struct Configuration {
        public struct Key: Hashable {
            let value: String
        }

        let key: Key
        let userDefaults: UserDefaults

        public init(key: Key, userDefaults: UserDefaults) {
            self.key = key
            self.userDefaults = userDefaults
        }
    }

    let defaultValue: () -> Value
    let config: Configuration

    override public func setValue(_ newValue: Value) {
        config.userDefaults.setValue(newValue, forKey: config.key.value)
    }

    override func getValue() -> Value {
        guard let storedValue = config.userDefaults.value(forKey: config.key.value) as? Value
        else {
            let newValue = defaultValue()
            setValue(newValue)
            return newValue
        }

        return storedValue
    }

    public init(configuration: Configuration, defaultValue: @escaping () -> Value) {
        self.config = configuration
        self.defaultValue = defaultValue
    }
}
