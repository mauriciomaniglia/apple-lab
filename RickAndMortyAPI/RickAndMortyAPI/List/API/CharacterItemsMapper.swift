import Foundation

final class CharacterItemsMapper {
    private struct Root: Decodable {
        let results: [RemoteCharacter]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteCharacter] {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCharacterLoader.Error.invalidData
        }

        return root.results
    }
}
