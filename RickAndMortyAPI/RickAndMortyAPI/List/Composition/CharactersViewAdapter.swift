import UIKit

final class CharactersViewAdapter: CharactersView {
   private weak var controller: CharactersViewController?
   private let imageLoader: CharacterImageDataLoader

   init(controller: CharactersViewController, imageLoader: CharacterImageDataLoader) {
       self.controller = controller
       self.imageLoader = imageLoader
   }

    func display(_ viewModel: CharactersViewModel) {
    controller?.display(viewModel.characters.map { model in
        let adapter = CharacterImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<CharacterCellController>, UIImage>(model: model, imageLoader: imageLoader)
        let view = CharacterCellController(delegate: adapter)
        adapter.presenter = CharacterImagePresenter(
            view: WeakRefVirtualProxy(view),
            imageTransformer: UIImage.init)

        return view
       })
   }
}
