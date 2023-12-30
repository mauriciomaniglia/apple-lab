import Foundation

public class CharacterImageDataLoaderWithFallbackComposite: CharacterImageDataLoader {
    private let primary: CharacterImageDataLoader
    private let fallback: CharacterImageDataLoader

    private class TaskWrapper: CharacterImageDataLoaderTask {
        var wrapped: CharacterImageDataLoaderTask?

        func cancel() {
            wrapped?.cancel()
        }
    }

    public init(primary: CharacterImageDataLoader, fallback: CharacterImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func loadImageData(from url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)

            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }
}
