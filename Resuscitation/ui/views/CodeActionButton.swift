import SwiftUI


struct CodeActionButton: View {
    
    static let DefaultButtonWidth: CGFloat = Self.halfOfScreenWithSpacing
    
    static let DefaultButtonHeight: CGFloat = CodeDialog.ButtonHeight
    
    
    @Inject private var presenter: Presenter
    
    
    private let title: String
    
    private let width: CGFloat
    
    private let height: CGFloat
    
    private let showCountDownOfLengthInSecondsOnClick: Int32?
    
    @State private var lastButtonClick: Date? = nil
    
    
    // count down view
    
    @State private var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    @State private var secondsRemaining: Int = 0
    
    @State private var countDown: CGFloat = 1
    
    @State private var didInformUserWillSoonCountToZero: Bool = false
    
    @Binding private var shouldResetTimer: Bool
    
    @State private var showVisuallyThatTimerIsRunningOut = false
    
    @State private var showVisuallyThatTimerHasCountDown = false
    
    @State private var textToSpeech = TextToSpeech()
    
    @State private var didCountDown: Bool = false
    
    
    private let action: () -> Void
    
    
    init(_ title: String, _ action: @escaping () -> Void) {
        self.init(title, Self.DefaultButtonWidth, action)
    }
    
    init(_ title: String, _ width: CGFloat = Self.DefaultButtonWidth, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, nil, .constant(false), action)
    }
    
    init(_ title: String, _ showCountDownOfLengthInSecondsOnClick: Int32? = nil, _ action: @escaping () -> Void) {
        self.init(title, Self.DefaultButtonWidth, showCountDownOfLengthInSecondsOnClick, action)
    }
    
    init(_ title: String, _ width: CGFloat = Self.DefaultButtonWidth,
         _ showCountDownOfLengthInSecondsOnClick: Int32? = nil, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, showCountDownOfLengthInSecondsOnClick, .constant(false), action)
    }
    
    init(_ title: String, _ width: CGFloat = Self.DefaultButtonWidth,
         _ showCountDownOfLengthInSecondsOnClick: Int32? = nil, _ resetTimer: Binding<Bool>, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, showCountDownOfLengthInSecondsOnClick, resetTimer, action)
    }
    
    init(_ title: String, _ width: CGFloat = Self.DefaultButtonWidth, _ height: CGFloat = Self.DefaultButtonHeight,
         _ showCountDownOfLengthInSecondsOnClick: Int32? = nil, _ resetTimer: Binding<Bool> = .constant(false), _ action: @escaping () -> Void) {
        self.title = title.localize()
        self.width = width
        self.height = height
        self.showCountDownOfLengthInSecondsOnClick = showCountDownOfLengthInSecondsOnClick
        self._shouldResetTimer = resetTimer
        self.action = action
        
        if let secondsRemaining = showCountDownOfLengthInSecondsOnClick {
            self._secondsRemaining = State(initialValue: Int(secondsRemaining))
        }
    }

    var body: some View {
        Button(action: self.buttonClicked) {
            GeometryReader { geometry in // needed to fix that otherwise button wasn't clickable on the left and on the right side
                VStack {
                    Spacer()
                    
                    Text(title)
                    
                    Spacer()
                    
                    showCountDownOfLengthInSecondsOnClick.map { _ in
                        HStack {
                            ProgressBar($countDown, true)
                            
                            Spacer()
                            
                            Text(presenter.formatDuration(secondsRemaining, 1)).onReceive(timer) { _ in self.updateCountDown() }
                                .monospaceFont()
                        }
                        .frame(height: 10)
                        .padding(.horizontal, 6)
                        .padding(.bottom, 4)
                    }
                }
                .frame(width: geometry.size.width)
            }
        }
        .frame(width: width, height: height, alignment: .center)
        .padding(.vertical, 0)
        .overlay(StandardBorder())
        .background(getBackgroundColor())
        .onDisappear {
            timer.upstream.connect().cancel() // prevents future text-to-speech even after having navigated away from CodeDialog for a long time
            textToSpeech.stop() // stops current text-to-speech
        }
    }
    
    private func getBackgroundColor() -> Color? {
        if showVisuallyThatTimerHasCountDown {
            return Color.red
        }
        
        if showVisuallyThatTimerIsRunningOut {
            return Color.orange
        }
        
        return nil
    }
    
    
    private func buttonClicked() {
        self.action()
        
        if showCountDownOfLengthInSecondsOnClick != nil {
            resetTimer()
        }
    }
    
    private func resetTimer() {
        lastButtonClick = Date()
        updateCountDown()
        
        didInformUserWillSoonCountToZero = false
        showVisuallyThatTimerIsRunningOut = false
        showVisuallyThatTimerHasCountDown = false
    }
    
    
    private func updateCountDown() {
        if shouldResetTimer {
            shouldResetTimer = false
            
            resetTimer()
            return
        }
        
        guard let lastButtonClick = lastButtonClick, let showCountDownOfLengthInSecondsOnClick = showCountDownOfLengthInSecondsOnClick else { return }
        
        let secondsSinceStart = Date().timeIntervalSince(lastButtonClick)
        
        let secondsRemaining = Int(showCountDownOfLengthInSecondsOnClick) - Int(secondsSinceStart)
        
        if secondsRemaining >= 0 {
            self.secondsRemaining = secondsRemaining
            self.countDown = CGFloat(secondsRemaining) / CGFloat(showCountDownOfLengthInSecondsOnClick)
            self.didCountDown = false
            
            let codeSettings = presenter.codeSettings
            
            if secondsRemaining == codeSettings.informUserCountSecondsBeforeTimerCountDown && didInformUserWillSoonCountToZero == false {
                didInformUserWillSoonCountToZero = true
                
                informUserTimerWillCountDownSoon(codeSettings)
            }
        }
        else {
            if didCountDown == false {
                informUserTimerHasCountDown(presenter.codeSettings)
            }
            
            self.didCountDown = true
            self.didInformUserWillSoonCountToZero = false
        }
    }
    
    private func informUserTimerWillCountDownSoon(_ codeSettings: CodeSettings) {
        if codeSettings.informUserOfTimerCountDownWithSound {
            DispatchQueue.global(qos: .background).async {
                let translated = String(format: NSLocalizedString("In %@ seconds %@", comment: ""), String(codeSettings.informUserCountSecondsBeforeTimerCountDown), title)
                textToSpeech.read(translated)
            }
        }
        
        if codeSettings.informUserOfTimerCountDownOptically {
            showVisuallyThatTimerIsRunningOut = true
        }
    }
    
    private func informUserTimerHasCountDown(_ codeSettings: CodeSettings) {
        if codeSettings.informUserOfTimerCountDownWithSound {
            DispatchQueue.global(qos: .background).async {
                speakOut(title)
            }
        }
        
        if codeSettings.informUserOfTimerCountDownOptically {
            showVisuallyThatTimerIsRunningOut = false
            showVisuallyThatTimerHasCountDown = true
        }
    }
    
    private func speakOut(_ text: String) {
        textToSpeech.read(text)
    }

}


struct CodeActionButton_Previews: PreviewProvider {

    static var previews: some View {
        CodeActionButton("Label") { }
    }

}
