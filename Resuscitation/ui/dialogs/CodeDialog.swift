import SwiftUI


struct CodeDialog: View {

    static private let SpaceBetweenButtons: CGFloat = 12
    
    static private let FullScreenButtonsWidth = screenWidth
    
    static private let HalfScreenButtonsWidth = halfOfScreenWithSpacing
    
    
    @Environment(\.presentationMode) var presentation
    
    
    private let presenter: Presenter
    
    
    private let log: ResuscitationLog
    
    private let startTime = Date()
    
    @State private var durationMillis: UInt64 = 0
    
    @State private var durationString: String = "0:00"
    
    @State private var audioRecordDurationString: String = "0:00"
    
    
    private let audioRecorder = AudioRecorder()
    
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    
    init(_ presenter: Presenter) {
        self.presenter = presenter
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let audioPath = documentsDirectory?.appendingPathComponent("code_record_.mp4")
        
        self.log = presenter.createNewResuscitationLog(startTime, audioPath)
        
        if let audioPath = audioPath {
            audioRecorder.record(audioPath)
        }
    }

    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Total time")
                    
                    Spacer()
                    
                    Text(durationString).onReceive(timer) { _ in
                        durationString = formatDurationString(startTime)
                        
                        if audioRecorder.isRecording {
                            self.audioRecordDurationString = formatDurationString(startTime)
                        }
                    }
                    .font(Font.body.monospacedDigit())
                }
                .frame(height: 30)
                .padding(.top, 20)
                .padding(.horizontal, 12)
                
                Spacer()
                
                VStack { // needed as a SwiftUI stack can handle only approximately 10 children
                    StandardButton("Rhythm Analysis", Self.FullScreenButtonsWidth, { self.rhythmAnalysis() })
                        .padding(.bottom, Self.SpaceBetweenButtons)
                    
                    Spacer()
                    
                    HStack {
                        StandardButton("Shock", self.shock)
                        
                        Spacer()
                        
                        StandardButton("Adrenalin", self.adrenalin)
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
                    Text("Recording") // TODO: change state if stop is pressed
                    
                    Button(action: { self.audioRecorder.stopRecording() }) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .accentColor(Color.red)
                    }
                    
                    Spacer()
                    
                    Text(audioRecordDurationString)
                }
                .disabled(self.audioRecorder.isRecording == false)
                .padding()
                .padding(.vertical, 12)
                
                Spacer()
                
                StandardButton("R O S C", Self.FullScreenButtonsWidth, self.stopResuscitation)
                    .padding(.bottom, 6)
            }
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
        presenter.resuscitationStopped(log)
        
        presentation.wrappedValue.dismiss()
    }
    
    
    private func addLogEntry(_ type: LogEntryType) {
        presenter.addLogEntry(log, Date(), type)
    }
    
    
    private func formatDurationString(_ startTime: Date) -> String {
        let secondsSinceStart = Date().timeIntervalSince(startTime)
        
        return String(format: "%02d:%02d", Int(secondsSinceStart / 60), Int(secondsSinceStart.truncatingRemainder(dividingBy: 60)))
    }

}


struct CodeDialog_Previews: PreviewProvider {

    static var previews: some View {
        CodeDialog(Presenter(ResuscitationPersistence()))
    }

}
