import Foundation

public protocol CharacterImageView {
    associatedtype Image
    func display(_ model: CharacterViewModel<Image>)
}

public final class CharacterImagePresenter<View: CharacterImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    public func didStartLoadingImageData(for model: Character) {
        view.display(CharacterViewModel(
            name: model.name,
            image: nil,
            species: model.species,
            gender: model.gender,
            isLoading: true,
            shouldRetry: false))
    }

    public func didFinishLoadingImageData(with data: Data, for model: Character) {
        let image = imageTransformer(data)

        view.display(CharacterViewModel(
            name: model.name,
            image: image,
            species: model.species,
            gender: model.gender,
            isLoading: false,
            shouldRetry: image == nil))
     }

    public func didFinishLoadingImageData(with error: Error, for model: Character) {
        view.display(CharacterViewModel(
            name: model.name,
            image: nil,
            species: model.species,
            gender: model.gender,
            isLoading: false,
            shouldRetry: true))
     }
}
