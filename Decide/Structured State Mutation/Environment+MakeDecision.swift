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


extension ApplicationEnvironment {
    //===------------------------------------------------------------------===//
    // MARK: - Sync
    //===------------------------------------------------------------------===//

    /// Synchronously applies state updates from ``Decision``,
    /// and then performs all produced ``Effect`` if any produced.
    /// **Note:**
    /// All effects execution will be postponed till after state updates,
    /// and will be executed at once.
    public func make(decision: Decision) {
        // We need to copy the code form `makeAwaiting` here because otherwise
        // if we dispatch it from here using `Task`,
        // we would interfere the order of state mutations,
        // making it possible for decision that made later to be executed before
        // the one that was made earlier, which won't be consistent across runs.
        // This violates the fundamental idea of structured state management
        // single reliable direction of state updates.
        let environment = DecisionEnvironment(self)
        decision.mutate(environment: environment)
        self.apply(transactions: environment.transactions)

        // here we only detach effects using unstructured concurrency.
        // This must be the only difference with `makeAwaiting`
        let effects = environment.effects
        Task.detached {
            await self.perform(effects: effects)
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
    public func makeAwaiting(decision: Decision) async {
        let environment = DecisionEnvironment(self)
        decision.mutate(environment: environment)
        apply(transactions: environment.transactions)

        await perform(effects: environment.effects)
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

    private func perform(effects: [Effect]) async {
        guard effects.count > 0 else { return }
        let environment = EffectEnvironment(self)
        await withTaskGroup(of: Void.self) { group in
            for effect in effects {
                await effect.perform(in: environment)
            }
            await group.waitForAll()
        }
    }
}
