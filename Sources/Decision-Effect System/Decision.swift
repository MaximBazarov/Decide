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

/// Decision is a core concept of the framework, it's the only way to mutate the app state.

/// ``execute(read:write:)`` method provides a ``StorageReader`` and ``StorageWriter`` that allow for the values to be read and written.
///
/// Decision also must produce an ``Effect`` that will be immediately executed. If you have nothing to execute asynchronously return ``NoOperation``.
public protocol Decision {
    @MainActor func execute(read: StorageReader, write: StorageWriter) -> Effect
}
