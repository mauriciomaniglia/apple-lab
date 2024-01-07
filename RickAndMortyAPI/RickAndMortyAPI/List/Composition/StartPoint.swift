import UIKit
import CoreData
import Combine

final class StartPoint {
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

    func viewController() -> UIViewController {
        return CharacterUIComposer.charactersComposedWith(
            characterLoader: makeRemoteCharacterLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback)
    }

    // MARK - Helpers

    private func makeRemoteCharacterLoaderWithLocalFallback() -> AnyPublisher<[Character], Error> {
        let remoteURL = URL(string: "https://rickandmortyapi.com/api/character")!

        return httpClient
            .dataTaskPublisher(for: remoteURL)
            .tryMap(CharacterItemsMapper.map)
            .caching(to: localCharacterLoader)
            .subscribe(on: scheduler)
            .fallback(to: localCharacterLoader.loadPublisher)
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
