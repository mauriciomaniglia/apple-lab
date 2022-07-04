//
//  SandwichStore.swift
//  Sandwiches
//
//  Created by Mauricio Maniglia on 04/07/22.
//

import Foundation

class SandwichStore: ObservableObject {
    @Published var sandwiches: [Sandwich]

    init(sandwiches: [Sandwich] = []) {
        self.sandwiches = sandwiches
    }
}

let testStore = SandwichStore(sandwiches: testData)
