import SwiftUI

struct FilmDetailScreen: View {
    let film: Film

    @State private var viewModel = FilmDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                FilmImageView(urlPath: film.bannerImage)
                    .frame(height: 300)
                    .containerRelativeFrame(.horizontal)

                VStack(alignment: .leading) {
                    Text(film.title)
                    Divider()
                    Text("Characters")
                        .font(.title3)

                    switch viewModel.state {
                    case .idle: EmptyView()
                    case .loading: ProgressView()
                    case .loaded(let people):
                        ForEach(people) { person in
                            Text(person.name)
                        }
                    case .error(let error):
                        Text(error)
                            .foregroundStyle(Color.red)
                    }
                }
                .padding()
            }
        }
        .task {
            await viewModel.fetch(for: film)
        }
    }
}

#Preview {
    let film = try! MockGhibliService().fetchFilm()
    FilmDetailScreen(film: film)
}
