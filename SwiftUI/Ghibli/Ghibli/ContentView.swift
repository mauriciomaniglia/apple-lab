import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {

            }
            Tab("Favorites", systemImage: "heart") {

            }
            Tab("Settings", systemImage: "gear") {

            }
            Tab(role: .search) {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
