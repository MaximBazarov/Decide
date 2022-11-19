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

import OSLog

final class Signposter {
    let id: OSSignpostID
    let signposter: OSSignposter

    init() {
        self.signposter = OSSignposter(subsystem: "im.mks.decide.signpost", category: "Core")
        self.id = signposter.makeSignpostID()
    }

    nonisolated func emitEvent(_ name: StaticString) {
        signposter.emitEvent(name, id: id)
    }
}
