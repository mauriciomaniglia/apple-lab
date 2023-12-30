import Foundation

public protocol CharacterImageDataLoaderTask {
    func cancel()
}

public protocol CharacterImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> CharacterImageDataLoaderTask
}
