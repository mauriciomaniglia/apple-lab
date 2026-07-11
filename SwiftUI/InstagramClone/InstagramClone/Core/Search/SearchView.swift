import SwiftUI

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(1 ... 20, id: \.self) { user in
                        HStack {
                            Image("alyx")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text("Alyx Vance")
                                    .fontWeight(.semibold)
                                Text("Resistance Fighter")
                            }
                            .font(.footnote)

                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                .searchable(text: $searchText,
                            placement: .navigationBarDrawer,
                            prompt: "Search...")
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchView()
}
