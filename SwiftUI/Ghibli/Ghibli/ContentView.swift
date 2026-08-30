import SwiftUI

struct ContentView: View {
    @State private var filmsViewModel = FilmViewModel()

    var body: some View {
        TabView {
            Tab("Movies", systemImage: "movieclapper") {
                FilmsScreen(viewModel: filmsViewModel)
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
