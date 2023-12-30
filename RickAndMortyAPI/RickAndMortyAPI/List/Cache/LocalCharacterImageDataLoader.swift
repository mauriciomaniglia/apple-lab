import Foundation

public final class LocalCharacterImageDataLoader {
    private let store: CharacterImageDataStore

    public init(store: CharacterImageDataStore) {
        self.store = store
    }
}

extension LocalCharacterImageDataLoader: CharacterImageDataCache {
    public typealias SaveResult = CharacterImageDataCache.Result

    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }

            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalCharacterImageDataLoader: CharacterImageDataLoader {

    private final class LoadImageDataTask: CharacterImageDataLoaderTask {
        private var completion: ((CharacterImageDataLoader.Result) -> Void)?

        init(_ completion: @escaping (CharacterImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: CharacterImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    public func loadImageData(from url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }

            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                })
            }

        return task
    }
}
