import Foundation
import Combine

public class CharactersLoadMoreAdapter {
    private let characterLoader: (Int) -> AnyPublisher<[Character], Error>
    private var cancellable: Cancellable?
    private var charactersCount = 0

    var presenter: CharactersPresenter?
    var viewController: CharactersViewController?
    var loadMoreCell: LoadMoreCell?

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
        cancellable = characterLoader(page)
            .receive(on: DispatchQueue.main)
            .map(checkLoadMore(cachedItems:))
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case .failure:
                        self?.loadMoreCell?.isLoading = false
                        self?.loadMoreCell?.message = "Couldn't connect to server"
                    }
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
