import CoreData


extension String {
    
    var isCoreDataId: Bool {
        return self.starts(with: "x-coredata://")
    }
    
}

extension NSManagedObject {
    
    var objectIDAsString: String {
        return self.objectID.uriRepresentation().absoluteString
    }
    
}

extension NSManagedObjectContext {
    
    func objectByID<T : NSManagedObject>(_ objectID: String) -> T? {
        if objectID.isCoreDataId {
            if let url = URL(string: objectID) {
                if let managedObjectId = self.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    let object = try? self.existingObject(with: managedObjectId) as? T
                    if object?.isFault == false {
                        return object
                    }
                }
            }
        }
        
        return nil
    }
    
}
