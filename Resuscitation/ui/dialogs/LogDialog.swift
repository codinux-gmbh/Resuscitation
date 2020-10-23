import SwiftUI


struct LogDialog: View {
    
    static private let TimeFormat = DateFormatter()
    
    private static let initializer: Void = {
        TimeFormat.dateFormat = "HH:mm"
    }()
    
    
    private let presenter: Presenter
    
    private let audioPlayer = AudioPlayer()
    
    @State private var playbackProgress: CGFloat = 0
    
    @State private var playbackTime: String = ""
    
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    
    private let log: ResuscitationLog
    
    private let entries: [LogEntry]
    
    
    init(_ logInfo: ResuscitationLogInfo, _ presenter: Presenter) {
        self.presenter = presenter
        
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
                List(entries) { entry in
                    HStack {
                        Text(presenter.translateLogEntryType((entry as LogEntry).type))
                        
                        Spacer()
                        
                        Text(presenter.formatTimeWithSeconds((entry as LogEntry).time))
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
