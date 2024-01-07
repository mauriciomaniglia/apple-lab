import XCTest
import RickAndMortyAPI

class LoadCharacterFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()

        _ = try? sut.load()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_load_deliversCacheCharactersOnNonExpiredCache() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let nonExpiredTimestamp = fixCurrentDate.minusCharacterCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })

        expect(sut, toCompleteWith: .success(characters.models), when: {
            store.completeRetrieval(with: characters.local, timestamp: nonExpiredTimestamp)
        })
    }

    func test_load_deliversNoCacheCharacterOnCacheExpiration() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let expirationTimestamp = fixCurrentDate.minusCharacterCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: characters.local, timestamp: expirationTimestamp)
        })
    }

    func test_load_deliversNoCacheCharacterOnExpiredCache() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let expiredTimestamp = fixCurrentDate.minusCharacterCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: characters.local, timestamp: expiredTimestamp)
        })
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: anyNSError())

        _ = try? sut.load()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()

        _ = try? sut.load()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let nonExpiredTimestamp = fixCurrentDate.minusCharacterCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        store.completeRetrieval(with: characters.local, timestamp: nonExpiredTimestamp)

        _ = try? sut.load()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let expirationTimestamp = fixCurrentDate.minusCharacterCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        store.completeRetrieval(with: characters.local, timestamp: expirationTimestamp)

        _ = try? sut.load()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnExpiredCache() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let expiredTimestamp = fixCurrentDate.minusCharacterCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })
        store.completeRetrieval(with: characters.local, timestamp: expiredTimestamp)

        _ = try? sut.load()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalCharacterLoader, store: CharacterStoreSpy) {
        let store = CharacterStoreSpy()
        let sut = LocalCharacterLoader(store: store, currentDate: currentDate)

        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)

        return (sut, store)
    }

    private func expect(_ sut: LocalCharacterLoader, toCompleteWith expectedResult: Result<[Character], Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        action()

        let receivedResult = Result { try sut.load() }

        switch (receivedResult, expectedResult) {
        case let (.success(receivedImages), .success(expectedImages)):
            XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)

        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}

