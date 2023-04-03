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

/// ``Decide`` enables extreme modularity by not coupling components together,
/// but during debug it's important to trace the change to the origin.
///
/// `Context` represents this origin of the change by storing the information about
/// the point of execution e.g. class or function
/// as well as the location in the source code.
///
/// Conforms to the `Sendable` protocol to be used with Swift's concurrency model.
public final class Context: Sendable {

    /// The code entity where the execution happened
    public let symbol: String

    /// The file path where the execution happened.
    public let file: String

    /// The file identifier where the execution happened.
    public let fileID: String

    /// The line number where the execution happened.
    public let line: Int

    /// The column number where the execution happened.
    public let column: Int

    /// The name of the function where the execution happened.
    public let function: String

    /// Initializes a new `Context` with the provided symbol.
    public init<S>(symbol: S.Type, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        self.symbol = String(reflecting: symbol)
        self.file = file
        self.fileID = fileID
        self.line = line
        self.column = column
        self.function = function
    }

    /// Returns a new `Context` with the provided symbol and other properties.
    public static func here<S>(as symbol: S.Type = Context.self, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) -> Context {
        Self.init<S>(
            symbolName: String(reflecting: symbol),
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
    }

    private init(symbolName: String, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        self.symbol = symbolName
        self.file = file
        self.fileID = fileID
        self.line = line
        self.column = column
        self.function = function
    }
}

extension Context: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(symbol) (\(file):\(line):\(column))"
    }
}
