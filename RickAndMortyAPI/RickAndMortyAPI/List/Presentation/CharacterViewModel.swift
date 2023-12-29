import Foundation

public struct CharacterViewModel<Image> {
    public let name: String
    public let image: Image?
    public let species: String
    public let gender: String
    public let isLoading: Bool
    public let shouldRetry: Bool
}
