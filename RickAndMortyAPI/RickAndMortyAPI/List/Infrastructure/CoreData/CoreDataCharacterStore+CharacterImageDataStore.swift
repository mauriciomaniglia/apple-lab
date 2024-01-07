import Foundation

extension CoreDataCharacterStore: CharacterImageDataStore {

    public func insert(_ data: Data, for url: URL) throws {
        try performSync { context in
            Result {
                try ManagedCharacter.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            }
        }
    }

    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                try ManagedCharacter.first(with: url, in: context)?.data
            }
        }
    }

}
