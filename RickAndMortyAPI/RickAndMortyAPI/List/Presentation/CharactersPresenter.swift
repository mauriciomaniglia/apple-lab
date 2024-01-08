public protocol CharactersView {
    func display(_ characters: [Character])
}

public struct CharactersLoadingViewModel {
    public let isLoading: Bool
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

    private var charactersLoadError: String {
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
        charactersView.display(characters)
        loadingView.display(CharactersLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingCharacters(with error: Error) {
        errorView.display(.error(message: charactersLoadError))
        loadingView.display(CharactersLoadingViewModel(isLoading: false))
    }
}
