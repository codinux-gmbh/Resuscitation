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
                Text(presenter.formatDate(log.startTime))
                
                Spacer()
                
                Text(presenter.formatTime(log.startTime))
            }
            .padding()
            
            List(entries) { entry in
                HStack {
                    Text(presenter.translateLogEntryType((entry as LogEntry).type))
                    
                    Spacer()
                    
                    Text(presenter.formatTimeWithSeconds((entry as LogEntry).time))
                }
            }
            
            Button("Export", action: self.showExportLogOptionsActionSheet)
                .frame(width: Self.screenWidth, height: 40, alignment: .center)
        }
    }
    
    
    
    private func showExportLogOptionsActionSheet() {
        ActionSheet(
            nil,
            UIAlertAction.default("Print (PDF)") { self.exportLogForPrinting() },
            UIAlertAction.cancel()
        ).show()
    }
    
    private func exportLogForPrinting() {
        let logString = presenter.exportLogAsString(log)
        
        let attributes = [NSAttributedString.Key : Any]()
        let string = NSAttributedString(string: logString, attributes: attributes)
        let print = UISimpleTextPrintFormatter(attributedText: string)
        
        
        let activityViewController = UIActivityViewController(activityItems: [ logString, print ], applicationActivities: nil)
        
        let viewController = SceneDelegate.rootViewController
        
        // needed for iPad
        activityViewController.popoverPresentationController?.sourceView = viewController?.view
        
        viewController?.present(activityViewController, animated: true, completion: nil)
    }

}


struct LogDialog_Previews: PreviewProvider {

    static var previews: some View {
        LogDialog(ResuscitationLogInfo("", Date()), Presenter(ResuscitationPersistence()))
    }

}
