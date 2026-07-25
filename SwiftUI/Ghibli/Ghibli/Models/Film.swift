import Foundation

struct Film: Codable, Identifiable {
    let id: String
    let title: String
    let image: String
    let description: String
    let director: String
    let producer: String
    let bannerImage: String
    let releaseYear: String
    let duration: String
    let score: String
    let people: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, image, description, director, producer, people

        case bannerImage = "movie_banner"
        case releaseYear = "release_date"
        case duration = "running_time"
        case score = "rt_score"
    }
}

import Playgrounds

#Playground {
    let url = URL(string: "https://ghibliapi.vercel.app/films")!

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        _ = try JSONDecoder().decode([Film].self, from: data)
    } catch {
        print(error)
    }
}
