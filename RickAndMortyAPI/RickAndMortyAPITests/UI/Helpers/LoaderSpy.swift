import Foundation
import Combine
import RickAndMortyAPI

class LoaderSpy {
    private var characterRequests = [PassthroughSubject<[Character], Error>]()
    var loadCharacterCallCount: Int {
        return characterRequests.count
    }

    func loadPublisher() -> AnyPublisher<[Character], Error> {
        let publisher = PassthroughSubject<[Character], Error>()
        characterRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    func completeCharactersLoading(with characters: [Character] = [], at index: Int = 0) {
        characterRequests[index].send(characters)
        characterRequests[index].send(completion: .finished)
    }

    func completeCharacterLoadingWithError(at index: Int = 0) {
        characterRequests[index].send(completion: .failure(anyNSError()))
    }



    private var loadMoreRequests = [PassthroughSubject<[Character], Error>]()
    var loadMoreCallCount: Int {
        return loadMoreRequests.count
    }

    func loadMorePublisher(page: Int) -> AnyPublisher<[Character], Error> {
        let publisher = PassthroughSubject<[Character], Error>()
        loadMoreRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    func completeLoadMoreCharacters(with characters: [Character] = [], at index: Int = 0) {
        loadMoreRequests[index].send(characters)
        loadMoreRequests[index].send(completion: .finished)
    }

    func completeLoadMoreWithError(at index: Int = 0) {
        loadMoreRequests[index].send(completion: .failure(anyNSError()))
    }



    private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs = [URL]()

    func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
        let publisher = PassthroughSubject<Data, Error>()
        imageRequests.append((url, publisher))
        return publisher.handleEvents(receiveCancel: { [weak self] in
            self?.cancelledImageURLs.append(url)
        }).eraseToAnyPublisher()
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].publisher.send(imageData)
        imageRequests[index].publisher.send(completion: .finished)
    }

    func completeImageLoadingWithError(at index: Int = 0) {
        imageRequests[index].publisher.send(completion: .failure(anyNSError()))
    }
}
