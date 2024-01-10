import UIKit
import CoreData
import Combine

final class StartPoint {
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

    func viewController() -> UIViewController {
        let viewController = CharactersUIComposer.charactersComposedWith(
            characterLoader: makeRemoteCharacterLoaderWithLocalFallback, 
            characterLoadMore: makeLocalLoadMoreLoader,
            imageLoader: makeLocalImageLoaderWithRemoteFallback)

        return viewController
    }

    private func makeRemoteCharacterLoaderWithLocalFallback() -> AnyPublisher<[Character], Error> {
        makeRemoteCharacterLoader(page: 1)
            .caching(to: localCharacterLoader)
            .fallback(to: localCharacterLoader.loadPublisher)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
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

    private func makeLocalLoadMoreLoader(page: Int) -> AnyPublisher<[Character], Error> {
        localCharacterLoader.loadPublisher()
            .zip(makeRemoteCharacterLoader(page: page))
            .map { (cachedItems, newItems) in
                cachedItems + newItems
            }
            .caching(to: localCharacterLoader)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}
