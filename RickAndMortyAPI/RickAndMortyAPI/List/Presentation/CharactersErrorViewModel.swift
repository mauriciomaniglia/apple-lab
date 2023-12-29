public struct CharactersErrorViewModel {
    public let message: String?

    static var noError: CharactersErrorViewModel {
        return CharactersErrorViewModel(message: nil)
    }

    static func error(message: String) -> CharactersErrorViewModel {
        return CharactersErrorViewModel(message: message)
    }
}
