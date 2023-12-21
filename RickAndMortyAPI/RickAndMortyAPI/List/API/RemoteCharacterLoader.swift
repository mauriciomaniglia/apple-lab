import Foundation

public final class RemoteCharacterLoader: CharacterLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = CharacterLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch (result) {
            case let .success((data, response)):
                completion(RemoteCharacterLoader.map(data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try CharacterItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteCharacter {
    func toModels() -> [Character] {
        return map { Character(id: $0.id, name: $0.name, image: $0.image, species: $0.species, gender: $0.gender) }
    }
}
