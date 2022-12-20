//
//  File.swift
//  
//
//  Created by Maxim Bazarov on 18.12.22.
//

import Foundation
import SwiftUI
import Combine
import Inject

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
@MainActor public class CollectionStateAccess<State: CollectionState> {
    @Injected(\.decisionCore, lifespan: .permanent, scope: .shared) var core

    var stateUpdated: () -> Void = {}
    var unsubscribe: AnyCancellable?

    public subscript(
        _ id: State.ID,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) -> Binding<State.Value> {
        let context: Context = Context(
            className: function,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
        return Binding<State.Value>(
            get: {
                let value = self.core.instance.reader().callAsFunction(State.self, at: id, context: context)
                self.core.instance.observationSystem.subscribe(
                    observationID: ObjectIdentifier(self),
                    send: { [weak self] in
                        self?.stateUpdated()
                    },
                    for: State.key(at: id)
                )
                return value
            },
            set: { newValue in
                self.core.instance.writer().callAsFunction(newValue, into: State.self, at: id, context: context)
            }
        )
    }
}


@MainActor @propertyWrapper public struct BindCollection<State: CollectionState>: DynamicProperty {
    @Injected(\.decisionCore, lifespan: .permanent, scope: .shared) var core

    @ObservedObject var observedValue = ObservableAtomicValue()
    
    let stateAccess = CollectionStateAccess<State>()

    public var wrappedValue: CollectionStateAccess<State> {
        nonmutating get { stateAccess }
    }

    public var projectedValue: Binding<CollectionStateAccess<State>> {
        Binding(
            get: { wrappedValue },
            set: { _ in }
        )
    }

    let state: State.Type
    public init(_ state: State.Type) {
        self.state = state
        let send = observedValue.objectWillChange.send
        stateAccess.stateUpdated = {
            send()
        }
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
