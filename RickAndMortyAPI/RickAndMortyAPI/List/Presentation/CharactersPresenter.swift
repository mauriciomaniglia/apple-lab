public protocol CharactersView {
    func display(_ viewModel: CharactersViewModel)
}

public protocol CharactersLoadingView {
    func display(_ viewModel: CharactersLoadingViewModel)
}

public protocol CharactersErrorView {
    func display(_ viewModel: CharactersErrorViewModel)
}

public final class CharactersPresenter {
    private let charactersView: CharactersView
    private let loadingView: CharactersLoadingView
    private let errorView: CharactersErrorView

    private var feedLoadError: String {
        return "Couldn't connect to server"
     }

    public init(charactersView: CharactersView, loadingView: CharactersLoadingView, errorView: CharactersErrorView) {
        self.charactersView = charactersView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public static var title: String {
        return "My Characters"
    }

    public func didStartLoadingCharacters() {
        errorView.display(.noError)
        loadingView.display(CharactersLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingCharacters(with characters: [Character]) {
        charactersView.display(CharactersViewModel(characters: characters))
        loadingView.display(CharactersLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingCharacters(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(CharactersLoadingViewModel(isLoading: false))
    }
}
