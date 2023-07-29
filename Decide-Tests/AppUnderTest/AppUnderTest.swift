//===----------------------------------------------------------------------===//
//
// This source file is part of the DecItem.IDe package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the DecItem.IDe package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Item.IDentifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation
import Decide



/// Application That uses all available APIs of Decide.
/// Must provide 100% coverage of functionality Decide ships.
final class AppUnderTest: AtomicState {

    //===------------------------------------------------------------------===//
    // MARK: - Dependency Injection
    //===------------------------------------------------------------------===//

    @DefaultInstance var networking: Networking = URLSession.shared

    //===------------------------------------------------------------------===//
    // MARK: - Feature Flags
    //===------------------------------------------------------------------===//

    /// isEnabled["feature-flag-key"]
    final class FeatureFlag: KeyedState<String> {
        @Property var isEnabled: Bool = false
    }

    //===------------------------------------------------------------------===//
    // MARK: - Item List
    //===------------------------------------------------------------------===//
    @Property var selectedItemID: Item.ID?
    @Property var itemList: [Item.ID] = []

    /// Item properties
    final class Item: KeyedState<Item.ID> {
        typealias ID = UUID

        @Property var propString = "propString"
        @Mutable @Property var mutpropString = "mutpropString"
        @Property var isAvailable: Bool = true
    }

    //===------------------------------------------------------------------===//
    // MARK: - Item Editor
    //===------------------------------------------------------------------===//
    /// Editor for the item:
    /// - Add item
    /// - Edit curently selected item
    /// - Delete item
    ///
    final class Editor: AtomicState {

        /// An ID of the item that is currently edited.
        @Property var itemID: Item.ID?


        /// Decided to add and select a new item.
        struct MustAddAndSelectNewItem: Decision {
            func mutate(environment: DecisionEnvironment) -> [Effect] {
                let newID = Item.ID()
                environment[\AppUnderTest.$itemList].append(newID)
                environment[\AppUnderTest.$selectedItemID] = newID
                return []
            }
        }


        /// Fetch the list of items from the server and update `AppUndertest/itemList`
        actor FetchListOfItems: Effect {
            func perform(in env: EffectEnvironment) async {
                let net = await env.instance(
                    \AppUnderTest.$networking
                )
                let _ = await env[
                    \AppUnderTest.Item.$propString, at: Item.ID()
                ]
                let _: String? = try? await net.fetch(
                    URLRequest(url: URL(string: "hellofresh.com")!)
                )
                await env.make(decision: MustUpdateItemList())
            }

            struct MustUpdateItemList: Decision {
                func mutate(environment: DecisionEnvironment) -> [Effect] {
                    return []
                }
            }
        }
    }
}

struct Response: Codable {}

protocol Networking {
    func fetch<T: Codable>(
        _ request: URLRequest,
        decode: (Data) async throws -> T
    ) async throws -> T

    func fetch<T: Codable>(
        _ request: URLRequest
    ) async throws -> T
}

extension URLSession: Networking {
    func fetch<T>(_ request: URLRequest) async throws -> T where T : Decodable, T : Encodable {
        try await fetch(request, decode: { try JSONDecoder().decode(T.self, from: $0) })
    }

    func fetch<T: Codable>(
        _ request: URLRequest,
        decode: (Data) async throws -> T
    ) async throws -> T {
        let (data, _) = try await self.data(for: request)
        return try await decode(data)
    }
}


struct Request {

}
