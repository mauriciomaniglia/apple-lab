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
    public typealias SaveResult = CharacterCache.Result

    public func save(_ character: [Character], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedCharacter { [weak self] deletionResult in
            guard let self = self else { return }

            switch deletionResult {
                case .success:
                    self.cache(character, with: completion)
                case let .failure(error):
                    completion(.failure(error))
            }
        }
    }

    private func cache(_ character: [Character], with completion: @escaping (SaveResult) -> Void) {
        store.insert(character.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            completion(insertionResult)
        }
    }
}

extension LocalCharacterLoader {
    public typealias LoadResult = Result<[Character], Error>

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(cache)) where CharacterCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.localCharacters.toModels()))

            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalCharacterLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else  { return }

            switch result {
            case .failure:
                self.store.deleteCachedCharacter(completion: completion)

            case let .success(.some(cache)) where !CharacterCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedCharacter(completion: completion)

            case .success:
                completion(.success(()))
            }
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

