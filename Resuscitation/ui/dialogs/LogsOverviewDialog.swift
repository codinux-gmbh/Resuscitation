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
                ForEach(logs) { log in
                    NavigationLink(destination: LazyView(LogDialog(log, presenter))) {
                        HStack {
                            Text(presenter.formatDate(log.startTime))
                            
                            Spacer()
                            
                            Text(presenter.formatTime(log.startTime))
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationBarTitle("Logs", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
    }
    
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            let log = logs[offset]
            askUserToDeleteLog(log)
        }
    }
    
    private func askUserToDeleteLog(_ log: ResuscitationLogInfo) {
        UIAlert(
            "Really delete log '%@'?".localize(presenter.formatDate(log.startTime) + " " + presenter.formatTime(log.startTime)),
            "All data for this account will be permanently deleted locally.",
            UIAlertAction.destructive("Delete") { presenter.deleteResuscitationLog(log) },
            UIAlertAction.cancel()
        ).show()
    }

}


struct LogsOverviewDialog_Previews: PreviewProvider {

    static var previews: some View {
        LogsOverviewDialog(Presenter(ResuscitationPersistence()))
    }

}
