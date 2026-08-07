import SwiftUI

struct FilmDetailScreen: View {
    let film: Film

    @State private var viewModel = FilmDetailViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: film.bannerImage)) { phase in
                switch phase {
                case .empty:
                    Color.gray
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Text("Could not get image")
                @unknown default:
                    fatalError()
                }
            }
            
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
        .task {
            await viewModel.fetch(for: film)
        }
    }
}

#Preview {
    let film = try! MockGhibliService().fetchFilm()
    FilmDetailScreen(film: film)
}
