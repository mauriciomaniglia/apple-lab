import Foundation
import RickAndMortyAPI

class CharacterStoreSpy: CharacterStore {
    enum ReceivedMessage: Equatable {
        case deleteCacheCharacter
        case insert([LocalCharacter], Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedCharacter?, Error>?

    func deleteCachedCharacter() throws {
        receivedMessages.append(.deleteCacheCharacter)
        try deletionResult?.get()
    }

    func completeDeletion(with error: Error) {
        deletionResult = .failure(error)
    }

    func completeDeletionSuccessfully() {
        deletionResult = .success(())
    }

    func insert(_ characters:[LocalCharacter], timestamp: Date) throws {
        receivedMessages.append(.insert(characters, timestamp))
        try insertionResult?.get()
    }

    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }

    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }

    func retrieve() throws -> CachedCharacter? {
        receivedMessages.append(.retrieve)
        return try retrievalResult?.get()
    }

    func completeRetrieval(with error: Error) {
        retrievalResult = .failure(error)
    }

    func completeRetrievalWithEmptyCache() {
        retrievalResult = .success(.none)
    }

    func completeRetrieval(with characters: [LocalCharacter], timestamp: Date) {
        retrievalResult = .success(CachedCharacter(localCharacters: characters, timestamp: timestamp))        
    }
}
