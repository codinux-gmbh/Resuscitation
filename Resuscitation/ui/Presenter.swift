import SwiftUI


class Presenter {
    
    private let persistence: ResuscitationPersistence
    
    
    init(_ persistence: ResuscitationPersistence) {
        self.persistence = persistence
        
        Styles.initialize()
    }
    
    
    func createNewResuscitationLog(_ startTime: Date) -> ResuscitationLog {
        return persistence.createNewResuscitationLog(startTime)
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
    
    
    func formatDate(_ date: Date) -> String {
        return Styles.LogDateFormatter.string(from: date)
    }
    
    func formatTime(_ time: Date) -> String {
        return Styles.TimeFormatter.string(from: time)
    }
    
    func formatTimeWithSeconds(_ time: Date) -> String {
        return Styles.TimeFormatterWithSeconds.string(from: time)
    }
    
    
    func preventScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func reenableScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}
