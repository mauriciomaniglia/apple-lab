import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: CharactersLoadingView where T: CharactersLoadingView {
    func display(_ viewModel: CharactersLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CharacterImageView where T: CharacterImageView, T.Image == UIImage {
   func display(_ model: CharacterViewModel<UIImage>) {
       object?.display(model)
   }
}

extension WeakRefVirtualProxy: CharactersErrorView where T: CharactersErrorView {
   func display(_ viewModel: CharactersErrorViewModel) {
       object?.display(viewModel)
   }
}
