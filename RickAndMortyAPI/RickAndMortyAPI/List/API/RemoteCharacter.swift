import Foundation

struct RemoteCharacter: Decodable {
    let id: Int
    let name: String
    let image: URL
    let species: String
    let gender: String

    var item: Character {
        Character(id: id, name: name, image: image, species: species, gender: gender)
    }
}
