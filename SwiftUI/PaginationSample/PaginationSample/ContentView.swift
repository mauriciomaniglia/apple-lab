import SwiftUI

struct ContentView: View {
    @State private var viewModel = DataSetViewModel()

    var body: some View {
        ScrollView {
            CollectionTitle
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.items) { item in
                    ItemCell(item)
                        .onAppear {
                            if viewModel.shouldFetchNextBatch(lastVisibleItem: item) {
                                viewModel.triggerFetchTask = true
                            }
                        }
                }
                if viewModel.triggerFetchTask {
                    LoadingProgress
                }
            }
        }
        .contentMargins(20, for: .scrollContent)
        .task(id: viewModel.triggerFetchTask) {
            guard viewModel.triggerFetchTask else { return }
            await viewModel.fetchNextBatch()
            viewModel.triggerFetchTask = false
        }
    }

    var CollectionTitle: some View {
        HStack {
            Text("Items")
                .font(.title)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.bottom)
    }

    func ItemCell(_ item: Item) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: item.imageName)
                    .font(.title2)
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.title2)
                    Text(item.subtitle)
                        .font(.callout)
                }
                Spacer()
            }
            Divider()
        }
    }

    var LoadingProgress: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .padding(.top, 10)
            Spacer()
        }
    }
}
