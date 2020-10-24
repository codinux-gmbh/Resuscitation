import SwiftUI


class Presenter {
    
    private let persistence: ResuscitationPersistence
    
    
    init(_ persistence: ResuscitationPersistence) {
        self.persistence = persistence
        
        Styles.initialize()
    }
    
    
    func getCodeSettings() -> CodeSettings {
        return persistence.getCodeSettings()
    }
    
    func saveCodeSettings(_ codeSettings: CodeSettings) {
        persistence.saveCodeSettings(codeSettings)
    }
    
    
    func createNewResuscitationLog(_ startTime: Date, _ audioFilename: String? = nil) -> ResuscitationLog {
        return persistence.createNewResuscitationLog(startTime, audioFilename)
    }
    
    func addLogEntry(_ log: ResuscitationLog, _ time: Date, _ type: LogEntryType) {
        persistence.addLogEntry(log, time, type)
    }
    
    func resuscitationStopped(_ log: ResuscitationLog) {
        log.endTime = Date()
        
        persistence.updateLog(log)
    }
    
    func deleteResuscitationLog(_ logInfo: ResuscitationLogInfo) {
        let log = persistence.deleteResuscitationLog(logInfo.id)
        
        if let audioFilename = log.audioFilename, let audioPath = getAudioPath(audioFilename) {
            do {
                try FileManager.default.removeItem(at: audioPath)
            } catch {
                NSLog("Could not delete audio file \(audioFilename): \(error)")
            }
        }
    }
    
    
    func getResuscitationLogs() -> [ResuscitationLogInfo] {
        return persistence.getResuscitationLogs().sorted { $0.startTime >= $1.startTime }
    }
    
    func getResuscitationLog(_ logInfo: ResuscitationLogInfo) -> ResuscitationLog {
        return persistence.getResuscitationLog(logInfo.id)
    }
    
    
    func getAudioPath(_ audioFilename: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return documentsDirectory?.appendingPathComponent(audioFilename)
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
    
    func formatDateTime(_ date: Date?) -> String {
        return Styles.DateTimeFormatter.string(from: date!)
    }
    
    func formatDuration(_ startTime: Date) -> String {
        let secondsSinceStart = Date().timeIntervalSince(startTime)
        
        return formatDuration(secondsSinceStart)
    }
    
    func formatDuration(_ seconds: Int, _ countDecimalPlacesForMinutes: Int = 2) -> String {
        return formatDuration(Double(seconds), countDecimalPlacesForMinutes)
    }
    
    func formatDuration(_ seconds: Double, _ countDecimalPlacesForMinutes: Int = 2) -> String {
        return String(format: "%0\(countDecimalPlacesForMinutes)d:%02d", Int(seconds / 60), abs(Int(seconds.truncatingRemainder(dividingBy: 60))))
    }
    
    
    func preventScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func reenableScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}
