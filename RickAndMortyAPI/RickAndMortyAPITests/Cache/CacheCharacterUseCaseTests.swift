import XCTest
import RickAndMortyAPI

class CacheCharacterUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)

        try? sut.save(uniqueCharacters().models)

        XCTAssertEqual(store.receivedMessages, [.deleteCacheCharacter])
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessulDeletion() {
        let timestamp = Date()
        let character = uniqueCharacters()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        store.completeDeletionSuccessfully()

        try? sut.save(character.models)

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

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalCharacterLoader, store: CharacterStoreSpy) {
        let store = CharacterStoreSpy()
        let sut = LocalCharacterLoader(store: store, currentDate: currentDate)

        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)

        return (sut, store)
    }

    private func expect(_ sut: LocalCharacterLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        action()

        do {
            try sut.save(uniqueCharacters().models)
        } catch {
            XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
        }
    }
}

