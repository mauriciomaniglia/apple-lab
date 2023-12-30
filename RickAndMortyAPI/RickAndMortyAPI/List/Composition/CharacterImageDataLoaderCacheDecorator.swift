import Foundation

public class CharacterImageDataLoaderCacheDecorator: CharacterImageDataLoader {
    private let decoratee: CharacterImageDataLoader
    private let cache: CharacterImageDataCache

    public init(decoratee: CharacterImageDataLoader, cache: CharacterImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func loadImageData(from url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.saveIgnoringResult(data, for: url)
                return data
            })
        }
    }
}

private extension CharacterImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
