//
//  ContentView.swift
//  Shared
//
//  Created by Mauricio Maniglia on 03/07/22.
//

import SwiftUI

struct ContentView: View {
    var sandwiches: [Sandwich] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(sandwiches) { sandwich in
                    SandwichCell(sandwich: sandwich)
                }

                HStack {
                    Spacer()
                    Text("\(sandwiches.count) Sandwiches")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .navigationTitle("Sandwiches")

            Text("Select a sandwich")
                .font(.largeTitle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sandwiches: testData)
    }
}

struct SandwichCell: View {
    var sandwich: Sandwich

    var body: some View {
        NavigationLink(destination: SandwichDetail(sandwich: sandwich)) {
            HStack {
                Image(systemName: "photo")
                    .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text(sandwich.name)
                    Text("\(sandwich.ingredientCount) ingridents")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
