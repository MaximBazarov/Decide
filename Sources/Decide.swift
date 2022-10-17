////
////===----------------------------------------------------------------------===//
////
//// This source file is part of the Decide package open source project
////
//// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
//// open source project authors
//// Licensed under Apache License v2.0
////
//// See LICENSE.txt for license information
////
//// SPDX-License-Identifier: Apache-2.0
////
////===----------------------------------------------------------------------===//
////
//
//import Foundation
//import SwiftUI
//
//protocol ValueContainer {
//    associatedtype Value
//}
//
//protocol Atom: ValueContainer {
//    associatedtype Value
//    static func defaultValue() -> Value
//}
//
//struct Computation {
//
//}
//
//protocol Group: ValueContainer {
//    associatedtype Value
//    associatedtype ID: Hashable
//    static func defaultValue(for id: ID) -> Value
//}
//
//typealias TypeID = ObjectIdentifier
//
//enum StorageKey: Hashable {
//    static func == (lhs: StorageKey, rhs: StorageKey) -> Bool {
//        switch (lhs, rhs) {
//        case let (.atomic(lhs), .atomic(rhs)):
//            return TypeID(lhs as AnyObject) == TypeID(rhs as AnyObject)
//        case let (.grouped(lhs, lid), .grouped(rhs, rid)):
//            return TypeID(lhs as AnyObject) == TypeID(rhs as AnyObject)
//            && lid == rid
//        default:
//            return false
//        }
//    }
//
//    func hash(into hasher: inout Hasher) {
//        switch self {
//        case let .atomic(atom):
//            hasher.combine(TypeID(atom as AnyObject))
//        case let .grouped(group, id):
//            hasher.combine(TypeID(group as AnyObject))
//            hasher.combine(id)
//        }
//    }
//
//    case atomic(any Atom.Type)
//    case grouped(any Group.Type, AnyHashable)
//}
//
//var storage = [StorageKey: Any]()
//
//public protocol CanAccessStorage {}
//
//extension NSObject: CanAccessStorage {}
//
//@propertyWrapper
//final class State<Value> {
//    private let storageKey: StorageKey?
//
//    var wrappedValue: Value {
//        get {
//            guard let storageKey else { return defaultValue() }
//            if let storedValue = storage[storageKey] as? Value {
//                return storedValue
//            }
//
//            let new = defaultValue()
//            storage[storageKey] = new
//            return new
//        }
//    }
//
//    static subscript<EnclosingType>(
//        _enclosingInstance instance: EnclosingType,
//        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, Value>,
//        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, State<Value>>
//    ) -> Value {
//        get {
//            let state = instance[keyPath: storageKeyPath]
//            guard let storageKey = state.storageKey else { return state.defaultValue() }
//            if let storedValue = storage[storageKey] as? Value {
//                return storedValue
//            }
//
//            let new = state.defaultValue()
//            storage[storageKey] = new
//            return new
//        }
//        set {
//            let state = instance[keyPath: storageKeyPath]
//            guard let storageKey = state.storageKey else { return }
//            storage[storageKey] = state.defaultValue()
//        }
//    }
//
//    let defaultValue: () -> Value
//
////    internal init(
////        storageKey: StorageKey,
////        defaultValue: @escaping () -> Value
////    ) {
////        self.storageKey = storageKey
////        self.defaultValue = defaultValue
////    }
//
////    convenience init<T: Atom>(_ type: T.Type) where T.Value == Value {
////        self.init(
////            storageKey: .atomic(type),
////            defaultValue: T.defaultValue
////        )
////    }
////
////    convenience init<T: Group>(_ type: T.Type, at id: T.ID) where T.Value == Value {
////        self.init(
////            storageKey: .grouped(type, id),
////            defaultValue: { T.defaultValue(for: id) }
////        )
////    }
//}
//
//
//struct TaskState {
//    struct title: Atom {
//        static func defaultValue() -> String { "Untitled" }
//    }
//
//    struct isCompleted: Group {
//        static func defaultValue(for id: UUID) -> Bool
//        { false }
//    }
//}
//
//class Consumer {
//
////    @State(TaskState.title.self) var title
//    @State(TaskState.isCompleted.self, \Self.id) var state
//
//    var id: UUID = .init()
//
//    func test() {
//        print(state)
//        print(title)
//    }
//}
//
//protocol HasDefault {
//    associatedtype Value
//    static func defaultValue() -> Value
//}
//
//struct Storage<T: HasDefault> {
//    let values: [AnyHashable: T] = [:]
//
//    subscript<Value>(_ key: AnyHashable) -> Value {
//        get {
//            // Value wasn't set - nil
//            // Value was set - nil
//            let storedValue = values[key]
//            return  storedValue ?? T.defaultValue()
//        }
//    }
//}
//
//extension Optional: HasDefault {
//    typealias Value = Int?
//    static func defaultValue() -> Value { 9 }
//}
//
//let storage = Storage<Int?>()
//storage[1] = Optional<Int>.nil
