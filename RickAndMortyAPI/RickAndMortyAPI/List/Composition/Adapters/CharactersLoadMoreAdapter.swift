import Foundation
import Combine

public class CharactersLoadMoreAdapter {
    private let characterLoader: (Int) -> AnyPublisher<[Character], Error>
    private var cancellable: Cancellable?
    private var charactersCount = 0
    private var isLoading = false

    weak var presenter: CharactersPresenter?
    weak var viewController: CharactersViewController?
    weak var loadMoreCell: LoadMoreCell?

    init(characterLoader: @escaping (Int) -> AnyPublisher<[Character], Error>) {
        self.characterLoader = characterLoader
    }

    func showLoadMoreCell(_ viewController: CharactersViewController) {
        self.viewController = viewController

        let loadingCell = LoadMoreCell()
        loadingCell.isLoading = true
        viewController.tableView.tableFooterView = loadingCell
        loadMoreCell = loadingCell

        let itemsCount = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        let nextPage = Int(itemsCount / 20) + 1

        loadMore(page: nextPage)
    }

    private func loadMore(page: Int) {
        guard !isLoading else { return }

        isLoading = true

        cancellable = characterLoader(page)
            .dispatchOnMainQueue()
            .map(checkLoadMore(cachedItems:))
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case .failure:
                        self?.loadMoreCell?.message = "Couldn't connect to server"
                    }

                    self?.loadMoreCell?.isLoading = false
                    self?.isLoading = false
                }, receiveValue: { [weak self] characters in
                    self?.charactersCount = characters.count
                    self?.presenter?.didFinishLoadingCharacters(with: characters)
                })
    }

    private func checkLoadMore(cachedItems: [Character]) -> [Character] {
        if charactersCount == cachedItems.count {
            viewController?.didRequestLoadMoreCharacters = nil
            viewController?.tableView.tableFooterView = nil
        }

        return cachedItems
    }
}
