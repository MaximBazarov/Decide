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

/// Empty ``Decision`` or ``Effect`` ends the decision-effect loop.
public final class NoOperation: Decision, Effect {
    public func execute(read: StorageReader, write: StorageWriter) -> Effect { NoOperation() }
    public func perform() async -> Decision { NoOperation() }

    public init(){}
}
