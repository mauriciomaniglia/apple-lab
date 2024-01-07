import Foundation

public final class LocalCharacterLoader {
    private let store: CharacterStore
    private let currentDate: () -> Date

    public init(store: CharacterStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalCharacterLoader: CharacterCache {
    public func save(_ characters: [Character]) throws {
        try store.deleteCachedCharacter()
        try store.insert(characters.toLocal(), timestamp: currentDate())
    }
}

extension LocalCharacterLoader {
    public func load() throws -> [Character] {
        if let cache = try store.retrieve(), CharacterCachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.localCharacters.toModels()
        }
        return []
    }
}

extension LocalCharacterLoader {
    private struct InvalidCache: Error {}

    public func validateCache() throws {
        do {
            if let cache = try store.retrieve(), !CharacterCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
        } catch {
            try store.deleteCachedCharacter()
        }
    }
}

private extension Array where Element == Character {
    func toLocal() -> [LocalCharacter] {
        return map { LocalCharacter(id: $0.id, name: $0.name, image: $0.image, species: $0.species, gender: $0.gender) }
    }
}

private extension Array where Element == LocalCharacter {
    func toModels() -> [Character] {
        return map { Character(id: $0.id, name: $0.name, image: $0.image, species: $0.species, gender: $0.gender) }
    }
}

