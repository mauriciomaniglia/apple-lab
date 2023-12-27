import XCTest
import RickAndMortyAPI

class LoadCharacterFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

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

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let nonExpiredTimestamp = fixCurrentDate.minusCharacterCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: characters.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let expirationTimestamp = fixCurrentDate.minusCharacterCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: characters.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnExpiredCache() {
        let characters = uniqueCharacters()
        let fixCurrentDate = Date()
        let expiredTimestamp = fixCurrentDate.minusCharacterCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: characters.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let store = CharacterStoreSpy()
        var sut: LocalCharacterLoader? = LocalCharacterLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalCharacterLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }

        sut = nil
        store.completeRetrievalWithEmptyCache()

        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalCharacterLoader, store: CharacterStoreSpy) {
        let store = CharacterStoreSpy()
        let sut = LocalCharacterLoader(store: store, currentDate: currentDate)

        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)

        return (sut, store)
    }

    private func expect(_ sut: LocalCharacterLoader, toCompleteWith expectedResult: LocalCharacterLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expect result \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}

