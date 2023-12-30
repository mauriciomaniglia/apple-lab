public class CharacterLoaderWithFallbackComposite: CharacterLoader {
    private let primary: CharacterLoader
    private let fallback: CharacterLoader

    public init(primary: CharacterLoader, fallback: CharacterLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(completion: @escaping (CharacterLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)

            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
