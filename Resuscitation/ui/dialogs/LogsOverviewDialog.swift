import SwiftUI


struct LogsOverviewDialog: View {
    
    private let presenter: Presenter
    
    @State private var logs: [ResuscitationLogInfo] = [ResuscitationLogInfo]()
    
    @State var selectedLogs = Set<ResuscitationLogInfo>()

    
    init(_ presenter: Presenter) {
        self.presenter = presenter
        
        self._logs = State(initialValue: presenter.getResuscitationLogs())
    }
    

    var body: some View {
        Form {
            Section {
                ForEach(logs) { log in
                    NavigationLink(destination: LazyView(LogDialog(log, presenter))) {
                        HStack {
                            Text(presenter.formatDate(log.startTime))
                                .monospaceFont()

                            Spacer()

                            Text(presenter.formatTime(log.startTime))
                                .monospaceFont()
                        }
                    }
                }
                .onDelete(perform: askUserToDeleteLogs)
            }
        }
        .navigationBarTitle("Logs", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
    }
    
    
    private func askUserToDeleteLogs(at offsets: IndexSet) {
        for offset in offsets {
            let log = logs[offset]
            askUserToDeleteLog(log)
        }
    }
    
    private func askUserToDeleteLog(_ log: ResuscitationLogInfo) {
        UIAlert(
            "Really delete log '%@'?".localize(presenter.formatDate(log.startTime) + " " + presenter.formatTime(log.startTime)),
            "All data for this account will be permanently deleted locally.",
            UIAlertAction.destructive("Delete") { self.deleteLog(log) },
            UIAlertAction.cancel()
        ).show()
    }
    
    private func deleteLog(_ log: ResuscitationLogInfo) {
        presenter.deleteResuscitationLog(log)
        
        self.logs = presenter.getResuscitationLogs()
    }

}


struct LogsOverviewDialog_Previews: PreviewProvider {

    static var previews: some View {
        LogsOverviewDialog(Presenter(ResuscitationPersistence()))
    }

}
