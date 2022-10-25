//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decide package 
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

/// State that computes it's value for given id based on other state's values
public protocol ComputedCollectionState {
    /// Type of the state's value.
    associatedtype Value

    /// Type of the the identifier of the value
    associatedtype ID: Hashable

    /// Computes the value for given id using `Reader` function to read other states
    static func computed(/*read: Reader,*/ id: ID) -> Value

    /// Should the result of ``ComputedCollectionState/computed(id:)`` be stored in the ``StorageSystem``
    var shouldPersistValueInStorage: Bool { get }
}
