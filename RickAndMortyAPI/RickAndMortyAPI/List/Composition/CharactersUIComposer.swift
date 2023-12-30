public final class CharacterUIComposer {
    private init() {}

    public static func charactersComposedWith(characterLoader: CharacterLoader, imageLoader: CharacterImageDataLoader) -> CharactersViewController {
        let presentationAdapter = CharactersLoaderPresentationAdapter(characterLoader: MainQueueDispatchDecorator(decoratee: characterLoader))

        let charactersController = makeCharactersViewController(
            delegate: presentationAdapter,
            title: CharactersPresenter.title)

        presentationAdapter.presenter = CharactersPresenter(
            charactersView: CharactersViewAdapter(
                controller: charactersController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
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
