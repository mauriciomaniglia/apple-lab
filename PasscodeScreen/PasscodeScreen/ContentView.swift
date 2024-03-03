//
//  ContentView.swift
//  PasscodeScreen
//
//  Created by Mauricio Cesar on 02/03/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isAutenticated = false

    var body: some View {
        VStack {
            if isAutenticated {
                VStack {
                    Text("Hello Bro")
                }
            } else {
                PasscodeView()
            }
        }
    }
}

#Preview {
    ContentView()
}
