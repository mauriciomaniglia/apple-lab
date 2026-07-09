import SwiftUI

struct ProfileView: View {
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                // Header
                VStack(spacing: 10) {
                    HStack {
                        Image("gordon-freeman")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())

                        Spacer()

                        HStack(spacing: 8) {
                            UserStatView(value: 3, title: "Post")
                            UserStatView(value: 5, title: "Followers")
                            UserStatView(value: 2, title: "Following")
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gordon Freeman")
                            .font(.footnote)
                            .fontWeight(.semibold)

                        Text("Black Mesa Research Facility")
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    Button {

                    } label: {
                        Text("Edit Profile")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 360, height: 32)
                            .foregroundColor(.black)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 1))
                    }

                    Divider()
                }

                // Post grid
                LazyVGrid(columns: gridItems, spacing: 1) {
                    ForEach(0 ... 15, id: \.self) { index in
                        Image("gordon-freeman")
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {

                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
