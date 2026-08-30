import SwiftUI

struct FilmsScreen: View {
    let viewModel: FilmViewModel

    var body: some View {
        NavigationStack {
            FilmListView(viewModel: viewModel)
                .navigationTitle("Ghibli Movies")
        }
        .task {
            await viewModel.fetch()
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FilmViewModel(service: MockGhibliService())

    FilmsScreen(viewModel: viewModel)
}
