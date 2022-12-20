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

import Foundation

//===----------------------------------------------------------------------===//
// MARK: - Effect
//===----------------------------------------------------------------------===//

public protocol Effect {

    /// Encloses the asynchronous execution.
    /// Produces the ``Decision`` that describes the state updates with the result.
    /// - Returns: Decision that describes state updates required after the async execution.
    func perform(read: StorageReader) async -> Decision
}


extension Effect {
    public var debugDescription: String {
        Self.pretty(String(reflecting: Self.self))
    }

    static func pretty(_ value: String) -> String {
        let name = value.split(separator: ".").last ?? "<UNTITLED>"
        return String(name)
    }
}


public struct EffectDecision: Decision {
    let effect: Effect

    public func execute(read: StorageReader, write: StorageWriter) -> Effect {
        effect
    }
}

public extension Effect {
    var asDecision: Decision {
        EffectDecision(effect: self)
    }
}
