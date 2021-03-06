import SwiftUI


struct CodeDialog: View {

    static private let SpaceBetweenButtons: CGFloat = 12
    
    static private let FullScreenButtonsWidth = screenWidth
    
    static private let HalfScreenButtonsWidth = halfOfScreenWithSpacing
    
    
    @Environment(\.presentationMode) var presentation
    
    
    private let presenter: Presenter
    
    private let codeSettings: CodeSettings
    
    
    private let log: ResuscitationLog
    
    private let audioFilename: String
    
    private let startTime = Date()
    
    @State private var durationMillis: UInt64 = 0

    @State private var durationString: String = "0:00"

    @State private var audioRecordDurationString: String = "0:00"
    
    
    private let audioRecorder = AudioRecorder()
    
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    
    init(_ presenter: Presenter) {
        self.presenter = presenter
        
        self.codeSettings = presenter.codeSettings
        
        self.audioFilename = "code_record_\(presenter.formatDateTime(Date())).mp4"
        
        self.log = presenter.createNewResuscitationLog(startTime, audioFilename)
        
        _durationString = State(initialValue: presenter.formatDuration(startTime, 2))
        _audioRecordDurationString = State(initialValue: presenter.formatDuration(audioRecorder.duration))
        
        presenter.preventScreenLock()
        
        if codeSettings.recordAudio {
            startRecording()
        }
    }

    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Total time")
                    
                    Spacer()
                    
                    Text(durationString).onReceive(timer) { _ in
                        durationString = presenter.formatDuration(startTime, 2)
                        
                        if audioRecorder.isRecording {
                            audioRecordDurationString = presenter.formatDuration(audioRecorder.duration)
                        }
                    }
                    .monospaceFont()
                }
                .frame(height: 30)
                .padding(.top, 20)
                .padding(.horizontal, 12)
                
                Spacer()
                
                VStack { // needed as a SwiftUI stack can handle only approximately 10 children
                    StandardButton("Rhythm Analysis", Self.FullScreenButtonsWidth, codeSettings.rhythmAnalysisTimerInSeconds, self.rhythmAnalysis)
                        .padding(.bottom, Self.SpaceBetweenButtons)
                    
                    Spacer()
                    
                    HStack {
                        StandardButton("Shock", codeSettings.shockTimerInSeconds, self.shock)
                        
                        Spacer()
                        
                        StandardButton("Adrenalin", codeSettings.adrenalinTimerInSeconds, self.adrenalin)
                    }
                    .padding(.bottom, Self.SpaceBetweenButtons)
                    
                    HStack {
                        StandardButton("Amiodaron", self.amiodaron)
                        
                        Spacer()
                        
                        StandardButton("IO/IV", self.ioIv)
                    }
                    .padding(.bottom, Self.SpaceBetweenButtons)

                    HStack {
                        StandardButton("Airway", self.airway)

                        Spacer()

                        StandardButton("LUCAS", self.lucas)
                    }
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: audioRecorder.isRecording ? "pause.rectangle.fill" : "play.rectangle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.red)
                    
                    Text(audioRecorder.isRecording ? "Recording" : "Resume recording")
                    
                    Spacer()
                    
                    Text(audioRecordDurationString)
                        .monospaceFont()
                }
                .padding()
                .padding(.vertical, 12)
                .makeBackgroundTapable()
                .onTapGesture {
                    self.toggleRecording()
                }
                
                Spacer()
                
                StandardButton("R O S C", Self.FullScreenButtonsWidth, self.stopResuscitation)
                    .padding(.bottom, 6)
            }
        }
        .onDisappear {
            presenter.reenableScreenLock()
        }
        .hideNavigationBar()
    }
    
    
    private func rhythmAnalysis() {
        addLogEntry(.rhythmAnalysis)
    }
    
    private func shock() {
        addLogEntry(.shock)
    }
    
    private func adrenalin() {
        addLogEntry(.adrenalin)
    }
    
    private func amiodaron() {
        addLogEntry(.amiodaron)
    }
    
    private func ioIv() {
        addLogEntry(.ioIv)
    }
    
    private func airway() {
        addLogEntry(.airway)
    }
    
    private func lucas() {
        addLogEntry(.lucas)
    }
    
    private func stopResuscitation() {
        stopRecording()
        
        presenter.resuscitationStopped(log)
        
        presentation.wrappedValue.dismiss()
    }
    
    
    private func toggleRecording() {
        if audioRecorder.isRecording {
            audioRecorder.pause()
        }
        else {
            startRecording()
        }
    }
    
    private func startRecording() {
        if let audioPath = presenter.getAudioPath(audioFilename) {
            audioRecorder.record(audioPath)
        }
    }
    
    private func stopRecording() {
        audioRecorder.stop()
    }
    
    
    private func addLogEntry(_ type: LogEntryType) {
        presenter.addLogEntry(log, Date(), type)
    }

}


struct CodeDialog_Previews: PreviewProvider {

    static var previews: some View {
        CodeDialog(Presenter(ResuscitationPersistence()))
    }

}
