import UIKit
import CoreData
import Combine

final class CharactersUIComposer {
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

    func viewController() -> UIViewController {
        let viewController = CharactersViewController()
        viewController.didRequestCharactersRefresh = makeRemoteCharacterLoaderWithLocalFallback
        viewController.title = CharactersPresenter.title

        let viewAdapter = CharactersViewAdapter(controller: viewController, imageLoader: makeLocalImageLoaderWithRemoteFallback)

        presenter = CharactersPresenter(
                    charactersView: viewAdapter,
                    loadingView: WeakRefVirtualProxy(viewController),
                    errorView: WeakRefVirtualProxy(viewController))

        return viewController
    }

    private func makeRemoteCharacterLoaderWithLocalFallback() {
        let remoteURL = URL(string: "https://rickandmortyapi.com/api/character")!

        cancellable = httpClient
            .dataTaskPublisher(for: remoteURL)
            .tryMap(CharacterItemsMapper.map)
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
}
