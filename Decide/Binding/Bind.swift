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


/**
 (!) Limited support for non SwiftUI objects,
 caveat is that each value this object observes will call the `onUpdate`.
 it will lead to multiple updates even when there should be one update.
 Might cause to many renderings in UIKit views.
 TODO: Improve support merging updates in one update,
 may be throttling to one per 0.5 sec )(60sec/120framesPerSec)
 */
@propertyWrapper
@MainActor
public final class Bind<Root, Value> where Root: StateRoot {

    let statePath: KeyPath<Root, ObservableValue<Value>>

    var environment = SharedEnvironment.default

    public init(
        _ statePath: KeyPath<Root, ObservableValue<Value>>,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.statePath = statePath
    }

    public static subscript<EnclosingObject>(
        _enclosingInstance instance: EnclosingObject,
        wrapped wrappedKeyPath: KeyPath<EnclosingObject, Value>,
        storage storageKeyPath: KeyPath<EnclosingObject, Bind>
    ) -> Value
    where EnclosingObject: EnvironmentObservingObject
    {
        get {
            let wrapperInstance = instance[keyPath: storageKeyPath]
            let root = wrapperInstance.environment.get(Root.self)
            let observableValue = root[keyPath: wrapperInstance.statePath]

#warning("""
TODO: Squash updates of any values this instance is subscribed to,
to one update to instance.
""")
            let observer = Observer(wrapperInstance) { [weak instance] in
                instance?.onChange()
            }


            return observableValue.getValueSubscribing(observer: observer)
        }
        set {
            let wrapperInstance = instance[keyPath: storageKeyPath]
            let root = wrapperInstance.environment.get(Root.self)
            let observableValue = root[keyPath: wrapperInstance.statePath]
            observableValue.set(value: newValue)
        }
    }

    @available(*, unavailable, message: "@DefaultBind can only be enclosed by EnvironmentObservingObject.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
}


