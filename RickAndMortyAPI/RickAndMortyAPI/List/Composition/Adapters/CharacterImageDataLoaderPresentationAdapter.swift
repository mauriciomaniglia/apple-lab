import Foundation
import Combine

final class CharacterImageDataLoaderPresentationAdapter<View: CharacterImageView, Image>: CharacterCellControllerDelegate where View.Image == Image {

    private let model: Character
    private let imageLoader: (URL) -> CharacterImageDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: CharacterImagePresenter<View, Image>?

    init(model: Character, imageLoader: @escaping (URL) -> CharacterImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)

        let model = self.model
        cancellable = imageLoader(model.image)
            //.dispatchOnMainQueue()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case let .failure(error):
                        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                    }

                }, receiveValue: { [weak self] data in
                    self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                })
    }

    func didCancelImageRequest() {
        cancellable?.cancel()        
    }
}
