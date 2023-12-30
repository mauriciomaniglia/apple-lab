import SwiftUI
import CoreData

struct CharactersViewControllerRepresentable: UIViewControllerRepresentable {
    var store: CharacterStore & CharacterImageDataStore = {
        try! CoreDataCharacterStore(
            storeURL: NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite"))
    }()

    func makeUIViewController(context: Context) -> UINavigationController {
        let remoteURL = URL(string: "https://rickandmortyapi.com/api/character")!
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))

        let remoteCharacterLoader = RemoteCharacterLoader(url: remoteURL, client:  httpClient)
        let remoteImageLoader = RemoteCharacterImageDataLoader(client: httpClient)
        let localCharacterLoader = LocalCharacterLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalCharacterImageDataLoader(store: store)

        //let vc = CharacterUIComposer.charactersComposedWith(characterLoader: remoteCharacterLoader, imageLoader: remoteImageLoader)

        let vc = CharacterUIComposer.charactersComposedWith(
            characterLoader: CharacterLoaderWithFallbackComposite(
                primary: CharacterLoaderCacheDecorator(
                    decoratee: remoteCharacterLoader,
                    cache: localCharacterLoader),
                fallback: localCharacterLoader),
            imageLoader: CharacterImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: CharacterImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader)))

        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
