import SwiftUI


struct LogsOverviewDialog: View {
    
    private let presenter: Presenter
    
    private let logs: [ResuscitationLogInfo]
    
    
    init(_ presenter: Presenter) {
        self.presenter = presenter
        
        self.logs = presenter.getResuscitationLogs()
    }
    

    var body: some View {
        Form {
            Section {
                List(logs) { log in
                    NavigationLink(destination: LazyView(LogDialog(log, presenter))) {
                        HStack {
                            Text(presenter.formatDate(log.startTime))
                            
                            Spacer()
                            
                            Text(presenter.formatTime(log.startTime))
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Logs", displayMode: .inline)
    }

}


struct LogsOverviewDialog_Previews: PreviewProvider {

    static var previews: some View {
        LogsOverviewDialog(Presenter(ResuscitationPersistence()))
    }

}
