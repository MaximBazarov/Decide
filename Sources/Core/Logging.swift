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

let logger = Logger(subsystem: "im.mks.decide", category: "Decide Internal")


protocol Event {
    var message: OSLogMessage { get }
}

//func log(_ event: Event, level: OSLogType = .default) {
//    logger.log(level: level, event.message)
//}

//struct StorageRead: Event {
//    var name: StaticString = "StorageSystem.getValue"
//
//    let key: StorageKey
//    let stage: Status; enum Status {
//        case started
//        case reported
//        case completed(CustomDebugStringConvertible)
//        case failed(Error)
//    }
//
//    var message: OSLogMessage {
//        fatalError()
////        switch stage {
////        case .started:
////            return OSLogMessage("\(name, privacy: .public) started for key: \(key.debugDescription)")
////        case let .completed(result):
////            return OSLogMessage("\(name, privacy: .public) returned \(key.debugDescription): \(result.debugDescription)")
////        case let .failed(error):
////            return OSLogMessage("\(name, privacy: .public) thrown \(error.localizedDescription)  for key: \(key.debugDescription)")
////        }
//    }
//}

extension StaticString: Hashable {
    public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
        ObjectIdentifier(lhs as AnyObject) == ObjectIdentifier(rhs as AnyObject)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.description)
    }
}
