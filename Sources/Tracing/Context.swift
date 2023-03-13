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

/// Represents an operation source context. Intended to be used in logging.
///
/// *Example:*  `MyClass` reads value in one of its functions,
/// the context for the reading operation would be that function call of the reading function.
///
/// **Parent context**: You can also link the parent context for the operation that require
/// that information.
public final class Context: Sendable {
    public let parent: Context?
    public let className: String
    public let file: String
    public let fileID: String
    public let line: Int
    public let column: Int
    public let function: String

    public init<S>(symbol: S.Type, parent: Context? = nil, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        self.className = String(reflecting: symbol)
        self.file = file
        self.fileID = fileID
        self.line = line
        self.column = column
        self.function = function
        self.parent = parent
    }

    init(className: String, parent: Context? = nil, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        self.className = className
        self.file = file
        self.fileID = fileID
        self.line = line
        self.column = column
        self.function = function
        self.parent = parent
    }

    // MARK: - .here()
    public static func here(file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) -> Context {
        Self.init(
            className: "",
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
    }
    public static func here<S>(as symbol: S.Type, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) -> Context {
        Self.init(
            symbol: symbol,
            file: file,
            fileID: fileID,
            line: line,
            column: column,
            function: function
        )
    }
}

extension Context: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\nsymbol: \(className),\nfile: \(file):\(line)\ncolumn\(column),\nfunction: \(function)"
    }
}
