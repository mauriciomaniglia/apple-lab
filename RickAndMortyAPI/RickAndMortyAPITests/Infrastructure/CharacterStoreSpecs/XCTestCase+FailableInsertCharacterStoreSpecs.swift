import XCTest
import RickAndMortyAPI

extension FailableInsertCharacterStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueCharacters().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: CharacterStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueCharacters().local, Date()), to: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
