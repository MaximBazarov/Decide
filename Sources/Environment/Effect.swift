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


/// Encloses the asynchronous execution of side-effect.
public protocol Effect {

    /// Called by ``Environment`` with the provided ``StorageReader``.
    /// Produces the ``Decision`` that describes the necessary state updates.
    ///
    /// - Returns: A ``Decision`` that describes the required state updates.
    func perform(read: StorageReader) async -> Decision
}
