import CoreData


class ResuscitationPersistence {

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Resuscitation")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    
    
    func createNewResuscitationLog(_ startTime: Date, _ audioPath: URL? = nil) -> ResuscitationLog {
        let newLog = ResuscitationLog(context: context)
        newLog.startTime = startTime
        newLog.audioPath = audioPath
        
        context.insert(newLog)
        
        saveChanges()
        
        return newLog
    }
    
    func updateLog(_ log: ResuscitationLog) {
        saveChanges()
    }
    
    @discardableResult
    func addLogEntry(_ log: ResuscitationLog, _ time: Date, _ type: LogEntryType) -> LogEntry {
        let newEntry = LogEntry(context: context)
        
        newEntry.time = time
        newEntry.type = map(type.rawValue)
        
        context.insert(newEntry)
        
        log.addToLogEntries(newEntry)
        
        saveChanges()
        
        return newEntry
    }
    
    func deleteResuscitationLog(_ logId: String) {
        let log = getResuscitationLog(logId)
        
        context.delete(log)
        
        saveChanges()
    }
    
    
    func getResuscitationLogs() -> [ResuscitationLogInfo] {
        var logs: [ResuscitationLog] = []
        
        do {
            let request: NSFetchRequest<ResuscitationLog> = ResuscitationLog.fetchRequest()
            request.returnsObjectsAsFaults = true
            
            request.propertiesToFetch = [ "startTime" ]
            
            try logs = context.fetch(request)
        } catch {
            NSLog("Could not request ResuscitationLogs: \(error)")
        }
        
        return map(logs)
    }
    
    private func map(_ logs: [ResuscitationLog]) -> [ResuscitationLogInfo] {
        return logs.map { map($0) }
    }
    
    private func map(_ log: ResuscitationLog) -> ResuscitationLogInfo {
        return ResuscitationLogInfo(log.objectIDAsString, log.startTime ?? Date()) // startTime is non-null, just to make compiler happy
    }
    
    
    func getResuscitationLog(_ logId: String) -> ResuscitationLog {
        if let log = context.objectByID(logId) as? ResuscitationLog {
            return log
        }
        
        // TODO: what to do in else case?
        return ResuscitationLog(context: context)
    }
    
    
    func saveChanges() {
        if (context.hasChanges) {
            do {
                try context.save()
            } catch {
                NSLog("Could not save changes: \(error)")
            }
        }
    }
    
    
    private func map(_ int: Int) -> Int32 {
        return Int32(int)
    }
    
    private func map(_ int: Int32) -> Int {
        return Int(int)
    }
    
}
