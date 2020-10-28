import SwiftUI


struct StandardButton: View {
    
    static let DefaultButtonWidth: CGFloat = Self.halfOfScreenWithSpacing
    
    static let DefaultButtonHeight: CGFloat = Self.screenHeight / 8 < 100 ? Self.screenHeight / 8 : 100
    
    
    @Inject private var presenter: Presenter
    
    
    private let title: String
    
    private let width: CGFloat
    
    private let height: CGFloat
    
    private let showCountDownOfLengthInSecondsOnClick: Int32?
    
    @State private var lastButtonClick: Date? = nil
    
    
    // count down view
    
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    @State private var secondsRemaining: Int = 0
    
    @State private var countDown: CGFloat = 1
    
    @State private var didInformUserWillSoonCountToZero: Bool = false
    
    @Binding private var shouldResetTimer: Bool
    
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
                            
                            Text(presenter.formatDuration(secondsRemaining, 1, true)).onReceive(timer) { _ in self.updateCountDown() }
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
        .overlay(StandardBorder())
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
            // TODO: implement button blink
        }
    }

}


struct StandardButton_Previews: PreviewProvider {

    static var previews: some View {
        StandardButton("Label") { }
    }

}
