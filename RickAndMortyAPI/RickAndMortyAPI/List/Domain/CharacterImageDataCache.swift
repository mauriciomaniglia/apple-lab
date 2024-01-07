import Foundation

public protocol CharacterImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
