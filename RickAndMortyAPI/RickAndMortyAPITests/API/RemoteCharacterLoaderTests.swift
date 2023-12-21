import XCTest
import RickAndMortyAPI

class RemoteCharacterLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromULR() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(fileURLWithPath: "http://a-given-http-url.com")
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in}

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(fileURLWithPath: "http://a-given-http-url.com")
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in}
        sut.load { _ in}

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples =  [199, 201, 300, 400, 500]

       samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidData = Data("invalid json".utf8)
            client.complete(withStatusCode: 200,  data: invalidData)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }

    func test_load_deliverItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
            id: "1",
            name: "a name",
            imageURL: URL(string: "http://some-url.com")!,
            species: "a specie",
            gender: "a gender")

        let item2 = makeItem(
            id: "2",
            name: "another name",
            imageURL: URL(string: "http://another-url.com")!,
            species: "another specie",
            gender: "another gender")

        let items = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }

    func test_load_doesNotDeliverAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteCharacterLoader? = RemoteCharacterLoader(url: url, client: client)

        var capturedResults = [RemoteCharacterLoader.Result]()
        sut?.load { capturedResults.append($0)}

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: Helpers

    private func makeSUT(url: URL = URL(fileURLWithPath: "http://a-http-url.com"), file: StaticString = #file, line: UInt = #line ) -> (sut: RemoteCharacterLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(url: url, client: client)

        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)

        return (sut, client)
    }

    private func failure(_ error: RemoteCharacterLoader.Error) -> RemoteCharacterLoader.Result {
        return .failure(error)
    }

    private func makeItem(id: String, name: String, imageURL: URL, species: String, gender: String) -> (model: Character, json: [String: Any]) {
        let item = Character(id: id, name: name, image: imageURL, species: species, gender: gender)

        let json = [
            "id": item.id,
            "name": item.name,
            "image": item.image.absoluteString,
            "species": item.species,
            "gender": item.gender,
            ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let json = ["results": items]

        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteCharacterLoader,
                        toCompleteWith expectedResult: RemoteCharacterLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {

        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
            case let (.failure(receivedError as RemoteCharacterLoader.Error), .failure(expectedError as RemoteCharacterLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
