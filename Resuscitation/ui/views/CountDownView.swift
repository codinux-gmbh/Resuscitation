import SwiftUI


struct CountDownView: View {
    
    private var presenter: Presenter
    
    private var codeSettings: CodeSettings
    
    
    private let title: String
    
    private let showCountDownOfLengthInSecondsOnClick: Int32
    
    private var lastButtonClick: Date
    
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    @State private var secondsRemaining: Int = 0
    
    @State private var countDown: CGFloat = 1
    
    @State private var didInformUserWillSoonCountToZero: Bool = false
    
    @State private var textToSpeech = TextToSpeech()
    
    @State private var didCountDown: Bool = false
    
    
    init(_ presenter: Presenter, _ title: String, _ lastButtonClick: Date, _ showCountDownOfLengthInSecondsOnClick: Int32) {
        self.presenter = presenter
        self.title = title
        self.lastButtonClick = lastButtonClick
        self.showCountDownOfLengthInSecondsOnClick = showCountDownOfLengthInSecondsOnClick
        
        self.codeSettings = presenter.codeSettings
    }
    

    var body: some View {
        HStack {
            ProgressBar($countDown, true)
            
            Spacer()
            
            Text(presenter.formatDuration(secondsRemaining, 1, true)).onReceive(timer) { _ in self.updateCountDown() }
                .monospaceFont()
        }
    }
    
    
    private func updateCountDown() {
        let secondsSinceStart = Date().timeIntervalSince(lastButtonClick)
        
        let secondsRemaining = Int(showCountDownOfLengthInSecondsOnClick) - Int(secondsSinceStart)
        
        if secondsRemaining >= 0 {
            self.secondsRemaining = secondsRemaining
            self.countDown = CGFloat(secondsRemaining) / CGFloat(showCountDownOfLengthInSecondsOnClick)
            self.didCountDown = false
            
            if secondsRemaining == codeSettings.informUserCountSecondsBeforeTimerCountDown && didInformUserWillSoonCountToZero == false {
                didInformUserWillSoonCountToZero = true
                
                informUserTimerWillCountDownSoon()
            }
            else if secondsRemaining < codeSettings.informUserCountSecondsBeforeTimerCountDown {
                didInformUserWillSoonCountToZero = false // needed as didInformUserWillSoonCountToZero currently gets only set when counted down -> if not counted down e.g. due to click it won't get reset -> cannot play again
            }
        }
        else {
            self.didCountDown = true
            self.didInformUserWillSoonCountToZero = false
        }
    }
    
    private func informUserTimerWillCountDownSoon() {
        if codeSettings.informUserOfTimerCountDownWithSound {
            DispatchQueue.global(qos: .background).async {
                textToSpeech.read(title)
            }
        }
        
        if codeSettings.informUserOfTimerCountDownOptically {
            // TODO: implement button blink
        }
    }

}


struct CountDownView_Previews: PreviewProvider {

    static var previews: some View {
        CountDownView(Presenter(ResuscitationPersistence()), "Shock", Date(), 120)
    }

}
