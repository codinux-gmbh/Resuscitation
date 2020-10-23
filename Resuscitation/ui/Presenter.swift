import SwiftUI


class Presenter {
    
    private let persistence: ResuscitationPersistence
    
    
    init(_ persistence: ResuscitationPersistence) {
        self.persistence = persistence
        
        Styles.initialize()
    }
    
    
    func createNewResuscitationLog(_ startTime: Date, _ audioPath: URL? = nil) -> ResuscitationLog {
        return persistence.createNewResuscitationLog(startTime, audioPath)
    }
    
    func addLogEntry(_ log: ResuscitationLog, _ time: Date, _ type: LogEntryType) {
        persistence.addLogEntry(log, time, type)
    }
    
    func resuscitationStopped(_ log: ResuscitationLog) {
        log.endTime = Date()
        
        persistence.updateLog(log)
    }
    
    
    func getResuscitationLogs() -> [ResuscitationLogInfo] {
        return persistence.getResuscitationLogs().sorted { $0.startTime >= $1.startTime }
    }
    
    func getResuscitationLog(_ logInfo: ResuscitationLogInfo) -> ResuscitationLog {
        return persistence.getResuscitationLog(logInfo.id)
    }
    
    
    func exportLogAsString(_ log: ResuscitationLog) -> String {
        var logString = ""
        
        (log.logEntries as? Set<LogEntry>)?.forEach { entry in
            logString += formatTimeWithSeconds(entry.time) + "\t\t" + translateLogEntryType(entry.type) + "\n"
        }
        
        return logString
    }
    
    func exportLogAsCsv(_ log: ResuscitationLog) -> String {
        var logString = ""
        
        (log.logEntries as? Set<LogEntry>)?.forEach { entry in
            logString += formatTimeWithSeconds(entry.time) + "," + translateLogEntryType(entry.type) + "\n"
        }
        
        return logString
    }
    
    
    func translateLogEntryType(_ typeInt: Int32) -> String {
        switch (Int(typeInt)) {
        case LogEntryType.rhythmAnalysis.rawValue:
            return "Rhythm Analysis".localize()
        case LogEntryType.shock.rawValue:
            return "Shock".localize()
        case LogEntryType.adrenalin.rawValue:
            return "Adrenalin".localize()
        case LogEntryType.amiodaron.rawValue:
            return "Amiodaron".localize()
        case LogEntryType.ioIv.rawValue:
            return "IO/IV".localize()
        case LogEntryType.airway.rawValue:
            return "Airway".localize()
        case LogEntryType.lucas.rawValue:
            return "LUCAS".localize()
        default:
            return "Unknown".localize()
        }
    }
    
    
    func formatDate(_ date: Date?) -> String {
        return Styles.LogDateFormatter.string(from: date!)
    }
    
    func formatTime(_ time: Date?) -> String {
        return Styles.TimeFormatter.string(from: time!)
    }
    
    func formatTimeWithSeconds(_ time: Date?) -> String {
        return Styles.TimeFormatterWithSeconds.string(from: time!)
    }
    
    
    func preventScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func reenableScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}
