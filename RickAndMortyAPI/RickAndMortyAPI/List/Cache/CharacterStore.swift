import Foundation

public typealias CachedCharacter = (localCharacters: [LocalCharacter], timestamp: Date)

public protocol CharacterStore {
    func deleteCachedCharacter() throws
    func insert(_ characters: [LocalCharacter], timestamp: Date) throws
    func retrieve() throws -> CachedCharacter?
}
