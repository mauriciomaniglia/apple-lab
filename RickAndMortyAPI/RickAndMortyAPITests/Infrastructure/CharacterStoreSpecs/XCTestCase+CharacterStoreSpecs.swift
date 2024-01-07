import XCTest
import RickAndMortyAPI

extension CharacterStoreSpecs where Self: XCTestCase {

    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        let character = uniqueCharacters().local
        let timestamp = Date()

        insert((character, timestamp), to: sut)

        expect(sut, toRetrieve: .success(CachedCharacter(localCharacters: character, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        let character = uniqueCharacters().local
        let timestamp = Date()

        insert((character, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(CachedCharacter(localCharacters: character, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueCharacters().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueCharacters().local, Date()), to: sut)

        let insertionError = insert((uniqueCharacters().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueCharacters().local, Date()), to: sut)

        let latestCharacter = uniqueCharacters().local
        let latestTimestamp = Date()
        insert((latestCharacter, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .success(CachedCharacter(localCharacters: latestCharacter, timestamp: latestTimestamp)), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueCharacters().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueCharacters().local, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

}

extension CharacterStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (character: [LocalCharacter], timestamp: Date), to sut: CharacterStore) -> Error? {
        do {
            try sut.insert(cache.character, timestamp: cache.timestamp)
            return nil
        } catch {
            return error
        }
    }

    @discardableResult
    func deleteCache(from sut: CharacterStore) -> Error? {
        do {
            try sut.deleteCachedCharacter()
            return nil
        } catch {
            return error
        }
    }

    func expect(_ sut: CharacterStore, toRetrieve expectedResult: Result<CachedCharacter?, Error>, file: StaticString = #file, line: UInt = #line) {
        let retrievedResult = Result { try sut.retrieve() }

        switch (expectedResult, retrievedResult) {
        case (.success(.none), .success(.none)),
             (.failure, .failure):
            break
        case let (.success(.some(expected)), .success(.some(retrieved))):
            XCTAssertEqual(retrieved.localCharacters, expected.localCharacters, file: file, line: line)
            XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
        default:
            XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
        }
    }

    func expect(_ sut: CharacterStore, toRetrieveTwice expectedResult: Result<CachedCharacter?, Error>, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
}
