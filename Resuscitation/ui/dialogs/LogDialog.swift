import SwiftUI


struct LogDialog: View {
    
    static private let TimeFormat = DateFormatter()
    
    private static let initializer: Void = {
        TimeFormat.dateFormat = "HH:mm"
    }()
    
    
    private let presenter: Presenter
    
    
    private let log: ResuscitationLog
    
    private let entries: [LogEntry]
    
    
    init(_ logInfo: ResuscitationLogInfo, _ presenter: Presenter) {
        self.presenter = presenter
        
        self.log = presenter.getResuscitationLog(logInfo)
        
        self.entries = ((log.logEntries as? Set<LogEntry>) ?? Set<LogEntry>()).sorted { $0.time! <= $1.time! }
    }
    

    var body: some View {
        VStack {
            HStack {
                Text(presenter.formatDate(log.startTime!))
                
                Spacer()
                
                Text(presenter.formatTime(log.startTime!))
            }
            .padding()
            
            List(entries) { entry in
                HStack {
                    Text(LocalizedStringKey(translateType((entry as LogEntry).type)))
                    
                    Spacer()
                    
                    Text(presenter.formatTimeWithSeconds((entry as LogEntry).time!))
                }
            }
        }
    }
    
    
    private func translateType(_ typeInt: Int32) -> String {
        switch (Int(typeInt)) {
        case LogEntryType.rhythmAnalysis.rawValue:
            return "Rhythm Analysis"
        case LogEntryType.shock.rawValue:
            return "Shock"
        case LogEntryType.adrenalin.rawValue:
            return "Adrenalin"
        case LogEntryType.amiodaron.rawValue:
            return "Amiodaron"
        case LogEntryType.ioIv.rawValue:
            return "IO/IV"
        case LogEntryType.airway.rawValue:
            return "Airway"
        case LogEntryType.lucas.rawValue:
            return "LUCAS"
        default:
            return "Unknown"
        }
    }

}


struct LogDialog_Previews: PreviewProvider {

    static var previews: some View {
        LogDialog(ResuscitationLogInfo("", Date()), Presenter(ResuscitationPersistence()))
    }

}
