import Foundation

public protocol CharacterCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ character: [Character], completion: @escaping (Result) -> Void)
}
