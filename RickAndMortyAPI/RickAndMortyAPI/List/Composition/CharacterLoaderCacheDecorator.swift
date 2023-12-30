public final class CharacterLoaderCacheDecorator: CharacterLoader {
    private let decoratee: CharacterLoader
    private let cache: CharacterCache

    public init(decoratee: CharacterLoader, cache: CharacterCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func load(completion: @escaping (CharacterLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
             if let feed = try? result.get() {
                 self?.cache.saveIgnoringResult(feed)
             }
             completion(result)
         }
    }
}

private extension CharacterCache {
   func saveIgnoringResult(_ feed: [Character]) {
       save(feed) { _ in }
   }
}
