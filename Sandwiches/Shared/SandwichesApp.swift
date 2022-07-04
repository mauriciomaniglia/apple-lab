//
//  SandwichesApp.swift
//  Shared
//
//  Created by Mauricio Maniglia on 03/07/22.
//

import SwiftUI

@main
struct SandwichesApp: App {
    @StateObject private var store = SandwichStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
