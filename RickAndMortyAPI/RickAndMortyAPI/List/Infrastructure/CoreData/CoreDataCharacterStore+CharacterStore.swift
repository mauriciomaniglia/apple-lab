import CoreData

extension CoreDataCharacterStore: CharacterStore {

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedCharacter(localCharacters: $0.localCharacters, timestamp: $0.timestamp)
                }
            })
        }
    }

    public func insert(_ characters: [LocalCharacter], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                let test = ManagedCharacter.characters(from: characters, in: context)
                managedCache.characters = test
                try context.save()
            })
        }
    }

    public func deleteCachedCharacter(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }

}
