//
//  ContentView.swift
//  Shared
//
//  Created by Mauricio Maniglia on 03/07/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store: SandwichStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.sandwiches) { sandwich in
                    SandwichCell(sandwich: sandwich)
                }
                .onMove(perform: moveSandwiches)
                .onDelete(perform: deleteSandwiches)

                HStack {
                    Spacer()
                    Text("\(store.sandwiches.count) Sandwiches")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .navigationTitle("Sandwiches")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    EditButton()
                }
                #endif
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Add", action: makeSandwich)
                }
            }

            Text("Select a sandwich")
                .font(.largeTitle)
        }
    }

    func makeSandwich() {
        withAnimation {
            store.sandwiches.append(Sandwich(name: "Gua bao", ingredientCount: 4))
        }
    }

    func moveSandwiches(from: IndexSet, to: Int) {
        withAnimation {
            store.sandwiches.move(fromOffsets: from, toOffset: to)
        }
    }

    func deleteSandwiches(offsets: IndexSet) {
        withAnimation {
            store.sandwiches.remove(atOffsets: offsets)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: testStore)
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
