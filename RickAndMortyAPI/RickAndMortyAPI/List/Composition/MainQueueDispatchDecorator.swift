import Foundation

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }

        completion()
     }
}

extension MainQueueDispatchDecorator: CharacterLoader where T == CharacterLoader {
    func load(completion: @escaping (CharacterLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: CharacterImageDataLoader where T == CharacterImageDataLoader {
   func loadImageData(from url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
       return decoratee.loadImageData(from: url) { [weak self] result in
           self?.dispatch { completion(result) }
       }
   }
}
