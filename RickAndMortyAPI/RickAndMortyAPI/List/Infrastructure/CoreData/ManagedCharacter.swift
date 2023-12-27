import CoreData

@objc(ManagedCharacter)
class ManagedCharacter: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var image: URL
    @NSManaged var species: String
    @NSManaged var gender: String
    @NSManaged var cache: ManagedCache
}

extension ManagedCharacter {

    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedCharacter? {
        let request = NSFetchRequest<ManagedCharacter>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedCharacter.image), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func characters(from localCharacters: [LocalCharacter], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localCharacters.map { local in
            let managed = ManagedCharacter(context: context)
            managed.id = local.id
            managed.name = local.name
            managed.image = local.image
            managed.species = local.species
            managed.gender = local.gender
            return managed
        })
    }

    var local: LocalCharacter {
        return LocalCharacter(id: id, name: name, image: image, species: species, gender: gender)
    }
}
