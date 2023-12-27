import Foundation
import RickAndMortyAPI

func uniqueCharacter() -> Character {
    return Character(id: "\(UUID().uuidString)", name: "any", image: anyURL(), species: "any", gender: "any")
}

func uniqueCharacters() -> (models: [Character], local: [LocalCharacter]) {
    let models = [uniqueCharacter(), uniqueCharacter()]
    let localCharacters = models.map { LocalCharacter(id: $0.id, name: $0.name, image: $0.image, species: $0.species, gender: $0.gender)}
    return (models, localCharacters)
}

extension Date {
    private var characterCacheMaxAgeInDays: Int {
        return 7
    }

    func minusCharacterCacheMaxAge() -> Date {
        return adding(days: -characterCacheMaxAgeInDays)
    }

    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
