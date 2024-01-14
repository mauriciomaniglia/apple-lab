import Foundation
import Combine

final class CharactersPresentationAdapter {    
    private let characterLoader: () -> AnyPublisher<[Character], Error>
    private var cancellable: Cancellable?
    private var isLoading = false

    var presenter: CharactersPresenter?

    init(characterLoader: @escaping () -> AnyPublisher<[Character], Error>) {
        self.characterLoader = characterLoader
    }

    func load() {
        guard !isLoading else { return }

        presenter?.didStartLoadingCharacters()
        isLoading = true

        cancellable = characterLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case let .failure(error):
                        self?.presenter?.didFinishLoadingCharacters(with: error)
                    }

                    self?.isLoading = false
                }, receiveValue: { [weak self] characters in
                    self?.presenter?.didFinishLoadingCharacters(with: characters)                    
                })
    }
}
