import Foundation

struct Person: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let gender: String
    let age: String
    let eyeColor: String
    let hairColor: String
    let films: [String]
    let species: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id, name, gender, age, films, species, url
        case eyeColor = "eye_color"
        case hairColor = "hair_color"
    }
}

import Playgrounds

#Playground {
    let url = URL(string: "https://ghibliapi.vercel.app/people/986faac6-67e3-4fb8-a9ee-bad077c2e7fe")!

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        _ = try JSONDecoder().decode(Person.self, from: data)
    } catch {
        print(error)
    }
}
