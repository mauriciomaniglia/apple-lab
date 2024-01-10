import Foundation
import Combine

public final class CharactersUIComposer {
    private init() {}

    public static func charactersComposedWith(
        characterLoader: @escaping () -> AnyPublisher<[Character], Error>,
        characterLoadMore: @escaping (Int) -> AnyPublisher<[Character], Error>,
        imageLoader: @escaping (URL) -> CharacterImageDataLoader.Publisher
    ) -> CharactersViewController {

        let presentationAdapter = CharactersPresentationAdapter(characterLoader: characterLoader)
        let loadMoreAdapter = CharactersLoadMoreAdapter(characterLoader: characterLoadMore)

        let viewController = CharactersViewController()
        viewController.didRequestCharactersRefresh = presentationAdapter.load
        viewController.didRequestLoadMoreCharacters = loadMoreAdapter.showLoadMoreCell(_:)
        viewController.title = CharactersPresenter.title

        let viewAdapter = CharactersViewAdapter(controller: viewController, imageLoader: imageLoader)

        let presenter = CharactersPresenter(
            charactersView: viewAdapter,
            loadingView: WeakRefVirtualProxy(viewController),
            errorView: WeakRefVirtualProxy(viewController))

        presentationAdapter.presenter = presenter

        loadMoreAdapter.viewController = viewController
        loadMoreAdapter.presenter = presenter

        return viewController
    }
}

