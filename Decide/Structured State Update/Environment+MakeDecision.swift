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
    // MARK: - Decision
    //===------------------------------------------------------------------===//
    
    public func make(decision: Decision) {
        let (transactions, effects) = split(decision: decision)
        apply(transactions: transactions)
        Task.detached {
            await self.execute(effects: effects)
        }
    }

    public func makeAwaiting(decision: Decision) async {
        let (transactions, effects) = split(decision: decision)
        apply(transactions: transactions)
        await execute(effects: effects)
    }

    func split(decision: Decision) -> (Set<Transaction>, [Effect]) {
        let environment = DecisionEnvironment(self)
        let effects = decision.mutate(environment: environment)
        return (environment.transactions, effects)
    }

    @MainActor func apply(transactions: Set<Transaction>) {
        let observers = transactions.reduce(into: Set<Observer>()) { result, transaction in
            result.formUnion(transaction.popObservers(self))
        }
        transactions.forEach { transaction in
            transaction.mutate(self)
        }
        notify(observers: observers)
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Effect
    //===----------------------------------------------------------------------===//

    func execute(effects: [Effect]) async {
        guard effects.count > 0 else { return }
        let environment = EffectEnvironment(self)
        await withTaskGroup(of: Void.self) { group in
            for effect in effects {
                await effect.perform(in: environment)
            }
            await group.waitForAll()
        }
    }

    //===----------------------------------------------------------------------===//
    // MARK: - Notify Observers
    //===----------------------------------------------------------------------===//

    func notify(observers: Set<Observer>) {
        observers.forEach{ $0.notify() }
    }
}
