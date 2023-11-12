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

public typealias EnvironmentMutation = (DecisionEnvironment) -> Void
/// Encapsulates value updates applied to the ``ApplicationEnvironment`` immediately.
/// Provided with an ``DecisionEnvironment`` to read and write state.
/// Might return an array of ``Effect``, that will be performed asynchronously
/// within the ``ApplicationEnvironment``.
@MainActor public protocol Decision {
    func mutate(_ env: DecisionEnvironment) -> Void
}

/// A restricted interface of ``ApplicationEnvironment`` provided to ``Decision``.
@MainActor public final class DecisionEnvironment {

    unowned var environment: ApplicationEnvironment

    var transactions: Set<Transaction> = []
    var effects: [Effect] = []

    init(_ environment: ApplicationEnvironment) {
        self.environment = environment
    }

    public subscript<Storage: AtomicStorage, Value>(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>
    ) -> Value {
        get {
            environment.observableState(keyPath).wrappedValue
        }
        set {
            transactions.insert(
                Transaction(keyPath, newValue: newValue)
            )
        }
    }

    public subscript<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value>(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        at identifier: Identifier
    ) -> Value {
        get {
            environment.observableState(keyPath, at: identifier).wrappedValue
        }
        set {
            transactions.insert(
                Transaction(keyPath, newValue: newValue, at: identifier)
            )
        }
    }

    public func perform<SideEffect: Effect>(effect: SideEffect) {
        effects.append(effect)
    }
}


/// Incapsulated a container and a new value.
/// Value later is used to apply on environment
/// using `.mutate()` or `.popObservers()`.
final class Transaction: Hashable {

    /// We store the ``ValueContainer`` KeyPath for the transaction identity.
    let identity: AnyHashable
    let _description: String

    /// called later when changes new value needs to be written in provided environment.
    let mutate: (ApplicationEnvironment) -> Void
    /// called later when observers of the container in the given environment are needed.
    let popObservers: (ApplicationEnvironment) -> Set<Observer>

    /// Instantiates a transaction of writing a `newValue` at `containerKeyPath`.
    /// - Parameters:
    ///   - containerKeyPath: ``ValueContainer`` KeyPath
    ///   - newValue: Value to be written.
    @MainActor init<Storage: AtomicStorage, Value>(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        newValue: Value
    ) {
        // We don't want Transaction to inherit generic of V in ValueContainer<V>,
        // so instead of storing the container we pack it into closures that are
        // of non-generic types and can be later provided with the environment.
        self.mutate = { environment in
            environment
                .observableState(keyPath)
                .wrappedValue = newValue
        }
        self.popObservers = { environment in
            environment
                .observableState(keyPath)
                .observerStorage
                .popObservers()
        }
        self.identity = keyPath
        self._description = String(describing: keyPath)
    }

    @MainActor init<Identifier: Hashable, Storage: KeyedStorage<Identifier>, Value>(
        _ keyPath: KeyPath<Storage, ObservableState<Value>>,
        newValue: Value,
        at identifier: Identifier
    ) {
        self.mutate = { environment in
            environment
                .observableState(keyPath, at: identifier)
                .wrappedValue = newValue
        }
        self.popObservers = { environment in
            environment
                .observableState(keyPath, at: identifier)
                .observerStorage
                .popObservers()
        }
        self.identity = KeyedIdentity(keyPath: keyPath, id: identifier)
        self._description = String(describing: keyPath)
    }

    struct KeyedIdentity: Hashable {
        let keyPath: AnyHashable
        let id: AnyHashable
    }

    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.identity == rhs.identity
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}

extension Transaction {
    var debugDescription: String {
        _description
    }
}

extension ApplicationEnvironment {
    //===------------------------------------------------------------------===//
    // MARK: - Sync
    //===------------------------------------------------------------------===//

    /// Synchronously applies state updates from ``Decision``,
    /// and then performs all produced ``Effect`` if any produced.
    /// **Note:**
    /// All effects execution will be postponed till after state updates,
    /// and will be executed at once.
    public func make(decision: Decision, context: Context) {
        // We need to copy the code form `makeAwaiting` here because otherwise
        // if we dispatch it from here using `Task`,
        // we would interfere the order of state mutations,
        // making it possible for decision that made later to be executed before
        // the one that was made earlier, which won't be consistent across runs.
        // This violates the fundamental idea of structured state management
        // single reliable direction of state updates.
        let environment = DecisionEnvironment(self)
        decision.mutate(environment)
        self.apply(transactions: environment.transactions)
        _decisionLog.trace("""
        MUT: \(decision.name):
        \t states: \(environment.transactions.map{$0.debugDescription}.joined(separator: ", "))
        \t (made at: \(context.debugDescription))
        """)
        let _effectsList = environment.effects.map{$0.name}.joined(separator: ", ")

        _decisionLog.trace("""
        EFF: \(decision.name):
        \t effects:  \(_effectsList)
        \t (made at: \(context.debugDescription))
        """)

        // here we only detach effects using unstructured concurrency.
        // This must be the only difference with `makeAwaiting`
        let effects = environment.effects
        Task.detached {
            await self.perform(effects: effects, context: context)
        }
    }

    //===------------------------------------------------------------------===//
    // MARK: - Async
    //===------------------------------------------------------------------===//

    /// Synchronously applies state updates from ``Decision``,
    /// and then awaits all produced ``Effect`` execution to finish
    /// if any effects are produced.
    /// **Note:**
    /// All effects execution will be postponed till after state updates,
    /// and will be executed at once.
    public func makeAwaiting(decision: Decision, context: Context) async {
        let environment = DecisionEnvironment(self)
        decision.mutate(environment)
        apply(transactions: environment.transactions)

        _decisionLog.trace("""
        \(decision.name):
        \t mutates: \(environment.transactions.map{$0.debugDescription}.joined(separator: ", "))
        \t\(context.debugDescription)
        """)
        let _effectsList = environment.effects.map{$0.name}.joined(separator: ", ")

        _decisionLog.trace("""
        \(decision.name):
        \t performs:  \(_effectsList)
        \t\(context.debugDescription)
        """)
        await perform(effects: environment.effects, context: context)
    }

    //===------------------------------------------------------------------===//
    // MARK: - apply Transactions
    //===------------------------------------------------------------------===//


    /// Applies transactions performing the environment mutations
    /// and notifies observers of these containers.
    @MainActor private func apply(transactions: Set<Transaction>) {
        let observers = transactions.reduce(into: Set<Observer>()) { result, transaction in
            result.formUnion(transaction.popObservers(self))
        }
        transactions.forEach { transaction in
            transaction.mutate(self)
        }
        observers.forEach{ $0.notify() }
    }

    //===------------------------------------------------------------------===//
    // MARK: - execute Effects
    //===------------------------------------------------------------------===//

    /// context is where execution was performed.
    private func perform(effects: [Effect], context: Context) async {
        guard effects.count > 0 else { return }
        let environment = EffectEnvironment(self)
        await withTaskGroup(of: Void.self) { group in
            for effect in effects {
                _effectLog.trace("""
                started \(effect.name):
                \t\(context.debugDescription)
                """)
                await effect.perform(in: environment)
            }
            await group.waitForAll()
        }
    }
}


extension Decision {
    var debugDescription: String {
        String(reflecting: self)
    }

    var name: String {
        String(describing: type(of: self))
    }
}
