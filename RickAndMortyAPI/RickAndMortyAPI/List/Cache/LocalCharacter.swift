import Foundation

public struct LocalCharacter: Equatable {
    public let id: String
    public let name: String
    public let image: URL
    public let species: String
    public let gender: String

    public init (id: String, name: String, image: URL, species: String, gender: String) {
        self.id = id
        self.name = name
        self.image = image
        self.species = species
        self.gender = gender
    }
}
