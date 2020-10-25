import SwiftUI


struct LogDialog: View {
    
    static private let LogEntryCalculationOptions = [ "Time since beginning", "Time since last same action", "Comparison to optimal time", "Off" ]
    
    static private let EntryTypesWithTimers = [ LogEntryType.rhythmAnalysis.rawValue, LogEntryType.shock.rawValue, LogEntryType.adrenalin.rawValue ]
    
    
    static private let TimeFormat = DateFormatter()
    
    private static let initializer: Void = {
        TimeFormat.dateFormat = "HH:mm"
    }()
    
    
    private let presenter: Presenter
    
    private let codeSettings: CodeSettings
    
    
    @State private var selectedLogEntryCalculationOption = Self.LogEntryCalculationOptions.count - 1
    
    
    private let audioPlayer = AudioPlayer()
    
    @State private var playbackProgress: CGFloat = 0
    
    @State private var playbackTime: String = ""
    
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    
    private let log: ResuscitationLog
    
    private let entries: [LogEntry]
    
    
    init(_ logInfo: ResuscitationLogInfo, _ presenter: Presenter) {
        self.presenter = presenter
        self.codeSettings = presenter.codeSettings
        
        self.log = presenter.getResuscitationLog(logInfo)
        
        self.entries = ((log.logEntries as? Set<LogEntry>) ?? Set<LogEntry>()).sorted { $0.time! <= $1.time! }
        
        self._playbackTime = State(initialValue: presenter.formatDuration(audioPlayer.currentTimeSeconds))
    }
    

    var body: some View {
        Form {
            HStack {
                Text(presenter.formatDate(log.startTime))
                
                Spacer()
                
                Text(presenter.formatTimeWithSeconds(log.startTime))
            }
            
            Section {
                Picker("Additional information", selection: $selectedLogEntryCalculationOption) {
                    ForEach(0 ..< Self.LogEntryCalculationOptions.count) { index in
                        Text(LocalizedStringKey(Self.LogEntryCalculationOptions[index]))
                    }
                }
            }
            
            Section {
                List(entries) { entry in
                    HStack {
                        Text(presenter.translateLogEntryType((entry as LogEntry).type))
                        
                        Spacer()
                        
                        if selectedLogEntryCalculationOption != Self.LogEntryCalculationOptions.count - 1 {
                            Text(calculateAdditionalLogEntryInfo(entry))
                                .monospaceFont()
                                .padding(.trailing, 18)
                        }
                        
                        Text(presenter.formatTimeWithSeconds((entry as LogEntry).time))
                            .monospaceFont()
                    }
                }
            }
            
            Section {
                GeometryReader { geometry in
                    Button(action: self.showExportLogOptionsActionSheet) {
                        VStack { // boy was that complicated to center the text at least horizontally and almost vertically
                            Spacer()
                            
                            Text("Export")
                            
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                    }
                }
            }
            
            Section(header: Text("Audio")) {
                HStack {
                    Button(action: self.togglePlayback) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                    }
                    
                    Group {
                        VStack { // needed to center ProgressBar vertically
                            Spacer()
                            
                            GeometryReader { geometry in
                                ProgressBar($playbackProgress)
                                    .frame(height: 20)
                                    .padding(.leading, 6)
                                    .gesture(DragGesture(minimumDistance: 0).onEnded { gesture in
                                        let relativePosition = gesture.startLocation.x / geometry.size.width
                                        self.setPlaybackToPosition(relativePosition)
                                    })
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Text(playbackTime).onReceive(timer) { _ in
                        playbackTime = presenter.formatDuration(audioPlayer.currentTimeSeconds)
                        playbackProgress = audioPlayer.progress
                    }
                    .monospaceFont()
                }
                .disabled(log.audioFilename == nil)
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    
    private func calculateAdditionalLogEntryInfo(_ entry: LogEntry) -> String {
        let selectionLogEntryOption = Self.LogEntryCalculationOptions[selectedLogEntryCalculationOption]
        
        switch selectionLogEntryOption {
        case Self.LogEntryCalculationOptions[0]:
            return calculateTimeSinceBeginning(entry)
        case Self.LogEntryCalculationOptions[1]:
            return calculateTimeSinceLastSameAction(entry)
        case Self.LogEntryCalculationOptions[2]:
            return compareWithOptimalTime(entry)
        default:
            return ""
        }
    }
    
    private func calculateTimeSinceBeginning(_ entry: LogEntry) -> String {
        if let logTime = entry.time, let startTime = log.startTime {
            let timeSinceBeginning = logTime.timeIntervalSince(startTime)
            
            return presenter.formatDuration(timeSinceBeginning)
        }
        
        return ""
    }
    
    private func calculateTimeSinceLastSameAction(_ entry: LogEntry) -> String {
        if let timeSinceLastSameAction = getTimeSinceLastSameAction(entry) {
            return presenter.formatDuration(timeSinceLastSameAction)
        }
        
        return ""
    }
    
    private func compareWithOptimalTime(_ entry: LogEntry) -> String {
        if Self.EntryTypesWithTimers.contains(Int(entry.type)) {
            if let timeSinceLastSameAction = getTimeSinceLastSameAction(entry) {
                if let optimalTime = getOptimalTime(entry) {
                    let diff = timeSinceLastSameAction - optimalTime
                    
                    return presenter.formatDuration(diff)
                }
            }
        }
        
        return ""
    }
    
    private func getOptimalTime(_ entry: LogEntry) -> TimeInterval? {
        switch Int(entry.type) {
        case LogEntryType.rhythmAnalysis.rawValue:
            return TimeInterval(codeSettings.rhythmAnalysisTimerInSeconds)
        case LogEntryType.shock.rawValue:
            return TimeInterval(codeSettings.shockTimerInSeconds)
        case LogEntryType.adrenalin.rawValue:
            return TimeInterval(codeSettings.adrenalinTimerInSeconds)
        default:
            return nil
        }
    }
    
    private func getTimeSinceLastSameAction(_ entry: LogEntry) -> TimeInterval? {
        let sameActionsBefore = entries.filter { $0.type == entry.type && $0.time! < entry.time! }
        
        if let lastOfSameAction = sameActionsBefore.last { // entries are already sorted chronologically -> simply take the 'oldest' entry of same type
            return entry.time!.timeIntervalSince(lastOfSameAction.time!)
        }
        
        return nil
    }
    
    
    private func togglePlayback() {
        if audioPlayer.isPlaying {
            pausePlayback()
        }
        else {
            startPlayback()
        }
    }
    
    private func startPlayback(_ result: ((Bool) -> Void)? = nil) {
        if let audioFilename = log.audioFilename, let audioPath = presenter.getAudioPath(audioFilename) {
            audioPlayer.play(audioPath, result)
        }
    }
    
    private func pausePlayback() {
        audioPlayer.pause()
    }
    
    private func setPlaybackToPosition(_ progress: CGFloat) {
        if audioPlayer.isPlaying == false {
            startPlayback { success in
                if success {
                    self.audioPlayer.setProgress(progress)
                }
            }
        }
        else {
            self.audioPlayer.setProgress(progress)
        }
    }
    
    
    private func showExportLogOptionsActionSheet() {
        ActionSheet(
            nil,
            UIAlertAction.default("CSV") { self.exportLogAsCsv() },
            UIAlertAction.default("Print (PDF)") { self.exportLogForPrinting() },
            UIAlertAction.cancel()
        ).show()
    }
    
    private func exportLogAsCsv() {
        let csv = presenter.exportLogAsCsv(log)
        
        share(csv)
    }
    
    private func exportLogForPrinting() {
        let logString = presenter.exportLogAsString(log)
        
        share(logString)
    }
    
    private func share(_ text: String) {
        let attributes = [NSAttributedString.Key : Any]()
        let string = NSAttributedString(string: text, attributes: attributes)
        let print = UISimpleTextPrintFormatter(attributedText: string)
        
        
        let activityViewController = UIActivityViewController(activityItems: [ text, print ], applicationActivities: nil)
        
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
