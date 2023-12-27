import XCTest
import RickAndMortyAPI

class CacheCharacterUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()

        sut.save(uniqueCharacters().models) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deleteCacheCharacter])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        sut.save(uniqueCharacters().models) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessages, [.deleteCacheCharacter])
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessulDeletion() {
        let timestamp = Date()
        let character = uniqueCharacters()
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(character.models) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCacheCharacter, .insert(character.local, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_save_successOnSuccessfullCacheInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = CharacterStoreSpy()
        var sut: LocalCharacterLoader? = LocalCharacterLoader(store: store, currentDate: Date.init)

        var receivedError = [LocalCharacterLoader.SaveResult]()
        sut?.save(uniqueCharacters().models, completion: { receivedError.append($0) })

        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedError.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = CharacterStoreSpy()
        var sut: LocalCharacterLoader? = LocalCharacterLoader(store: store, currentDate: Date.init)

        var receivedError = [LocalCharacterLoader.SaveResult]()
        sut?.save(uniqueCharacters().models, completion: { receivedError.append($0) })

        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedError.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalCharacterLoader, store: CharacterStoreSpy) {
        let store = CharacterStoreSpy()
        let sut = LocalCharacterLoader(store: store, currentDate: currentDate)

        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)

        return (sut, store)
    }

    private func expect(_ sut: LocalCharacterLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")

        var receivedError: Error?
        sut.save(uniqueCharacters().models) { result in
            if case let Result.failure(error) = result { receivedError = error }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
}

