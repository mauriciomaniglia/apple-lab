import SwiftUI

struct FilmListView: View {
    var viewModel: FilmViewModel

    var body: some View {
        NavigationStack {
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
                        Text(film.title)
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
        .task {
            await viewModel.fetch()
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FilmViewModel(service: MockGhibliService())

    FilmListView(viewModel: viewModel)
}
