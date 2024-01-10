import UIKit
import CoreData
import Combine

final class CharactersUIComposer {
    private lazy var baseURL = URL(string: "https://rickandmortyapi.com")!

    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.rick-and-morty.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()

    var store: CharacterStore & CharacterImageDataStore = {
        try! CoreDataCharacterStore(
            storeURL: NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite"))
    }()

    private lazy var localCharacterLoader: LocalCharacterLoader = {
        LocalCharacterLoader(store: store, currentDate: Date.init)
    }()

    private lazy var httpClient: URLSession = {
        URLSession(configuration: .ephemeral)
    }()

    private var presenter: CharactersPresenter?
    private var cancellable: Cancellable?
    private var controller: CharactersViewController?

    func viewController() -> UIViewController {
        let viewController = CharactersViewController()
        viewController.didRequestCharactersRefresh = makeRemoteCharacterLoaderWithLocalFallback
        viewController.didRequestLoadMoreCharacters = showLoadMoreCell(_:)
        viewController.title = CharactersPresenter.title

        let viewAdapter = CharactersViewAdapter(controller: viewController, imageLoader: makeLocalImageLoaderWithRemoteFallback)

        presenter = CharactersPresenter(
                    charactersView: viewAdapter,
                    loadingView: WeakRefVirtualProxy(viewController),
                    errorView: WeakRefVirtualProxy(viewController))

        controller = viewController

        return viewController
    }

    private func makeRemoteCharacterLoaderWithLocalFallback() {
        cancellable = makeRemoteCharacterLoader(page: 1)
            .caching(to: localCharacterLoader)
            .subscribe(on: scheduler)
            .fallback(to: localCharacterLoader.loadPublisher)
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

    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> CharacterImageDataLoader.Publisher {
        let localImageLoader = LocalCharacterImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient, scheduler] in
                httpClient
                    .dataTaskPublisher(for: url)
                    .tryMap(CharacterImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
                    .subscribe(on: scheduler)
                    .eraseToAnyPublisher()
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }

    private func makeRemoteCharacterLoader(page: Int) -> AnyPublisher<[Character], Error> {
        let url = CharacterEndpoint.get(page: page).url(baseURL: baseURL)

        return httpClient
                .dataTaskPublisher(for: url)
                .tryMap(CharacterItemsMapper.map)
                .eraseToAnyPublisher()
    }

    private func showLoadMoreCell(_ viewController: CharactersViewController) {
        let loadingCell = LoadMoreCell()
        loadingCell.isLoading = true
        viewController.tableView.tableFooterView = loadingCell

        let itemsCount = viewController.tableView(viewController.tableView, numberOfRowsInSection: 0)
        let nextPage = Int(itemsCount / 20) + 1

        makeLocalLoadMoreLoader(page: nextPage)
    }

    private func makeLocalLoadMoreLoader(page: Int) {
        cancellable = localCharacterLoader.loadPublisher()
            .zip(makeRemoteCharacterLoader(page: page))
            .map { (cachedItems, newItems) in
                (cachedItems + newItems, cachedItems.count)
            }
            .subscribe(on: scheduler)
            .receive(on: DispatchQueue.main)
            .map(checkLoadMore(cachedItems:newItemsCount:))
            .subscribe(on: scheduler)
            .caching(to: localCharacterLoader)
            .subscribe(on: scheduler)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case .failure:
                        let loadMoreView = self?.controller?.tableView.tableFooterView as? LoadMoreCell
                        loadMoreView?.isLoading = false
                        loadMoreView?.message = "Couldn't connect to server"
                    }
                }, receiveValue: { [weak self] characters in
                    self?.presenter?.didFinishLoadingCharacters(with: characters)
                })
    }

    private func checkLoadMore(cachedItems: [Character], newItemsCount: Int) -> [Character] {
        if newItemsCount == 0 {
            controller?.didRequestLoadMoreCharacters = nil
            controller?.tableView.tableFooterView = nil
        }

        return cachedItems
    }
}
