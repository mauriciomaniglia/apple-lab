import UIKit
import Combine

final class CharactersViewAdapter: CharactersView {
   private weak var controller: CharactersViewController?
   private let imageLoader: (URL) -> CharacterImageDataLoader.Publisher

   init(controller: CharactersViewController, imageLoader: @escaping (URL) -> CharacterImageDataLoader.Publisher) {
       self.controller = controller
       self.imageLoader = imageLoader
   }

    func display(_ characters: [Character]) {
        controller?.display(characters.map { model in
            let adapter = CharacterImageLoaderAdapter<WeakRefVirtualProxy<CharacterCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = CharacterCellController(delegate: adapter)
            adapter.presenter = CharacterImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            
            return view
        })
   }
}
