import Foundation

public final class CharacterItemsMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    private struct Root: Decodable {
        private let results: [RemoteCharacter]

        struct RemoteCharacter: Decodable {
            let id: Int
            let name: String
            let image: URL
            let species: String
            let gender: String

            var item: Character {
                Character(id: id, name: name, image: image, species: species, gender: gender)
            }
        }

        var characters: [Character] {
            results.map { Character(id: $0.id, name: $0.name, image: $0.image, species: $0.species, gender: $0.gender) }
        }
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Character] {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }

        return root.characters
    }
}
