import Foundation

extension CoreDataCharacterStore: CharacterImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (CharacterImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {

                try ManagedCharacter.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (CharacterImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedCharacter.first(with: url, in: context)?.data
            })
        }
    }

}
