//
//  File.swift
//  
//
//  Created by Maxim Bazarov on 18.12.22.
//

import Foundation
import SwiftUI
import Combine

/// State that represents a collection of values of the same type, accessed by id.
public protocol CollectionState {

    /// Type of the state's value.
    associatedtype Value

    /// Type of the the identifier of the value
    associatedtype ID: Hashable

    /// Default value for the state for given id, used if read before write.
    static func defaultValue(at id: ID) -> Value
}

extension CollectionState {
    static func key(at id: ID) -> StorageKey {
        StorageKey(type: Self.self, additionalKeys: [id])
    }
}


/// A wrapper of the collection states ``Observe`` to provide a get ``subscript(_:)`` for later access to the value.
@MainActor public final class CollectionStateAccess<ID, Value> {

    var get: (ID, Context) -> Value = { _, _ in
        preconditionFailure("CollectionStateAccess: `get` must be set after the initialisation.")
    }
    var set: (Value, ID, Context) -> Void = { _, _, _ in
        preconditionFailure("CollectionStateAccess: `set` must be set after the initialisation.")
    }

    public subscript(
        _ id: ID,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) -> Binding<Value> {
        let context: Context = Context(
            className: function,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
        return Binding<Value>(
            get: { self.get(id, context) },
            set: { value in self.set(value, id, context) }
        )
    }
}

@MainActor @propertyWrapper public struct BindCollection<State: CollectionState>: DynamicProperty {
    @Environment(\.decisionCore) var core

    @ObservedObject var observedValue = ObservableValue()

    public var wrappedValue: CollectionStateAccess<State.ID, State.Value> {
        nonmutating get { stateAccess }
    }

    public var projectedValue: Binding<CollectionStateAccess<State.ID, State.Value>> {
        Binding(
            get: { wrappedValue },
            set: { _ in }
        )
    }

    let state: State.Type
    let stateAccess = CollectionStateAccess<State.ID, State.Value>()

    public init(_ state: State.Type) {
        self.state = state

        let observedValue = ObservableValue()
        let read = core.reader()
        let write = core.writer()
        let subscribe = core.observationSystem.subscribe

        stateAccess.get =  { id, context in
            let value = read(State.self, at: id, context: context)
            subscribe(observedValue, State.key(at: id))
            return value
        }
        stateAccess.set = { newValue, id, context in
            write(newValue, into: State.self, at: id, context: context)
        }

        self.observedValue = observedValue
    }

    nonisolated public func update() {
        print("SwiftUI: dynamic property update for  \(state)")
    }
}


//===----------------------------------------------------------------------===//
// MARK: - Reader
//===----------------------------------------------------------------------===//

public extension StorageReader {
    func callAsFunction<T: CollectionState>(_ type: T.Type, at id: T.ID, context: Context = .here()) -> T.Value {
        return read(
            key: type.key(at: id),
            fallbackValue: { type.defaultValue(at: id) },
            shouldStoreDefaultValue: true,
            context: context
        )
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Writer
//===----------------------------------------------------------------------===//

public extension StorageWriter {
    func callAsFunction<T: CollectionState>(_ value: T.Value, into type: T.Type, at id: T.ID, context: Context = .here()) {
        write(
            value,
            for: type.key(at: id),
            onBehalf: nil,
            context: context
        )
    }
}

public final class ObservableCollectionValue: ObservableObject, Hashable {

    let id: AnyHashable
    init(id: AnyHashable) {
        self.id = id
    }

    public func send() { objectWillChange.send() }


    public static func == (lhs: ObservableCollectionValue, rhs: ObservableCollectionValue) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs) && lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
