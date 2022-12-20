//
//  File.swift
//  
//
//  Created by Maxim Bazarov on 20.12.22.
//


final class Observation: Hashable {
    let send: () -> Void

    let id: AnyHashable

    init(id: AnyHashable, _ send: @escaping () -> Void) {
        self.send = send
        self.id = id
    }

    static func == (lhs: Observation, rhs: Observation) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
