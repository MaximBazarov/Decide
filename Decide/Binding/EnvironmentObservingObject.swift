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

final class ChangesPublisher: ObservableObject {}

public protocol EnvironmentObservingObject: AnyObject {
    var environment: SharedEnvironment { get set}
    var onChange: () -> Void { get }
}
