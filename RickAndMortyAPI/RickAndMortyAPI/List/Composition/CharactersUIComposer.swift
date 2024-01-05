import Foundation
import Combine

public final class CharacterUIComposer {
    private init() {}

    public static func charactersComposedWith(
        characterLoader: @escaping () -> AnyPublisher<[Character], Error>,
        imageLoader: @escaping (URL) -> CharacterImageDataLoader.Publisher
    ) -> CharactersViewController {

        let presentationAdapter = CharactersLoaderPresentationAdapter(characterLoader: characterLoader)

        let charactersController = makeCharactersViewController(delegate: presentationAdapter, title: CharactersPresenter.title)

        let viewAdapter = CharactersViewAdapter(controller: charactersController, imageLoader: imageLoader)

        presentationAdapter.presenter = CharactersPresenter(
            charactersView: viewAdapter,
            loadingView: WeakRefVirtualProxy(charactersController),
            errorView: WeakRefVirtualProxy(charactersController))

        return charactersController
    }

    private static func makeCharactersViewController(delegate: CharactersViewControllerDelegate, title: String) -> CharactersViewController {
        let charactersController = CharactersViewController()
        charactersController.delegate = delegate
        charactersController.title = title
        return charactersController
    }
}
