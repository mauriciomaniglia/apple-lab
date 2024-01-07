import Foundation

public protocol CharacterImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
