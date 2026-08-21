import SwiftUI

struct FilmImageView: View {
    let urlPath: String

    var body: some View {
        AsyncImage(url: URL(string: urlPath)) { phase in
            switch phase {
            case .empty:
                Color(white: 0.8)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                    }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Text("Could not get image")
            @unknown default:
                fatalError()
            }
        }
    }
}

#Preview("banner image") {
    let url = URL.convertAssertImage(named: "bannerImage")

    FilmImageView(urlPath: url!.absoluteString)
}

#Preview("poster image") {
    let url = URL.convertAssertImage(named: "posterImage")

    FilmImageView(urlPath: url!.absoluteString)
        .frame(height: 150)
}
