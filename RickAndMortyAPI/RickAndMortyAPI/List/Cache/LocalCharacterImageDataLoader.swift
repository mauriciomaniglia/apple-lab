import Foundation

public final class LocalCharacterImageDataLoader {
    private let store: CharacterImageDataStore

    public init(store: CharacterImageDataStore) {
        self.store = store
    }
}

extension LocalCharacterImageDataLoader: CharacterImageDataCache {
    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalCharacterImageDataLoader: CharacterImageDataLoader {

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    public func loadImageData(from url: URL) throws -> Data  {
        do {
            if let imageData = try store.retrieve(dataForURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }

        throw LoadError.notFound
    }
}
