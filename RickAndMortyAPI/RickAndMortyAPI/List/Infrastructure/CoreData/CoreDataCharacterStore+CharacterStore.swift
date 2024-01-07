import CoreData

extension CoreDataCharacterStore: CharacterStore {

    public func retrieve() throws -> CachedCharacter? {
        try performSync { context in
            Result {
                try ManagedCache.find(in: context).map {
                    CachedCharacter(localCharacters: $0.localCharacters, timestamp: $0.timestamp)
                }
            }
        }
    }

    public func insert(_ characters: [LocalCharacter], timestamp: Date) throws {
        try performSync { context in
            Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                let test = ManagedCharacter.characters(from: characters, in: context)
                managedCache.characters = test
                try context.save()
            }
        }
    }

    public func deleteCachedCharacter() throws {
        try performSync { context in
            Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            }
        }
    }

}
