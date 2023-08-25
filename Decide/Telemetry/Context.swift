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

/// While enabling extreme modularity by decoupling components,
/// we must not loose the context of execution while debugging
/// or dealing with incidents.
///
/// Decide guaranties that every state mutation whether it's structured
/// or unstructured can be traced to the point of changes origin.
///
/// `Context` represents this origin of the change by storing the information about
/// the point of execution e.g. class or function
/// as well as the location in the source code.
///
public final class Context: Sendable {

    /// The file path where the execution happened.
    public let file: String

    /// The line number where the execution happened.
    public let line: Int

    public init(file: String = #fileID, line: Int = #line) {
        self.file = file
        self.line = line
    }
}

extension Context: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(file):\(line)"
    }
}
