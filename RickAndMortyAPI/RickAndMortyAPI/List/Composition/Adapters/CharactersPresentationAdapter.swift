import Foundation
import Combine

final class CharactersPresentationAdapter {    
    private let characterLoader: () -> AnyPublisher<[Character], Error>
    private var cancellable: Cancellable?

    var presenter: CharactersPresenter?

    init(characterLoader: @escaping () -> AnyPublisher<[Character], Error>) {
        self.characterLoader = characterLoader
    }

    func load() {
        presenter?.didStartLoadingCharacters()

        cancellable = characterLoader()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case let .failure(error):
                        self?.presenter?.didFinishLoadingCharacters(with: error)
                    }

                }, receiveValue: { [weak self] characters in
                    self?.presenter?.didFinishLoadingCharacters(with: characters)
                })
    }
}
