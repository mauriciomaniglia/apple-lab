import SwiftUI

struct FilmListView: View {
    var viewModel: FilmViewModel

    var body: some View {
        switch viewModel.state {
        case .idle:
            Text("No Films yet")
        case .loading:
            ProgressView {
                Text("Loading...")
            }
        case .loaded(let films):
            List(films) { film in
                NavigationLink(value: film) {
                    HStack {
                        FilmImageView(urlPath: film.image)
                            .frame(width: 100, height: 150)
                        Text(film.title)
                    }
                }
            }
            .navigationDestination(for: Film.self) { film in
                FilmDetailScreen(film: film)
            }
        case .error(let error):
            Text(error)
                .foregroundStyle(.red)
        }        
    }
}

#Preview {
    @Previewable @State var viewModel = FilmViewModel(service: MockGhibliService())

    FilmListView(viewModel: viewModel)
}
