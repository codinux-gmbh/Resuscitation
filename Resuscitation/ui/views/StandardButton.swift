import SwiftUI


struct StandardButton: View {
    
    static let DefaultButtonWidth: CGFloat = Self.halfOfScreenWithSpacing
    
    static let DefaultButtonHeight: CGFloat = Self.screenHeight / 8 < 100 ? Self.screenHeight / 8 : 100
    
    
    @Inject private var presenter: Presenter
    
    
    private let title: LocalizedStringKey
    
    private let width: CGFloat
    
    private let height: CGFloat
    
    private let showCountDownOfLengthInSecondsOnClick: Int?
    
    @State private var lastButtonClick: Date? = nil
    
    private let timerPublisher: Timer.TimerPublisher?
    
    @State private var secondsRemaining: Int = 0
    
    @State private var countDown: CGFloat = 1
    
    @State private var didCountDown: Bool = false
    
    private let action: () -> Void
    
    
    init(_ title: LocalizedStringKey, _ action: @escaping () -> Void) {
        self.init(title, Self.DefaultButtonWidth, action)
    }
    
    init(_ title: LocalizedStringKey, _ width: CGFloat = Self.DefaultButtonWidth, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, nil, action)
    }
    
    init(_ title: LocalizedStringKey, _ showCountDownOfLengthInSecondsOnClick: Int? = nil, _ action: @escaping () -> Void) {
        self.init(title, Self.DefaultButtonWidth, showCountDownOfLengthInSecondsOnClick, action)
    }
    
    init(_ title: LocalizedStringKey, _ width: CGFloat = Self.DefaultButtonWidth,
         _ showCountDownOfLengthInSecondsOnClick: Int? = nil, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, showCountDownOfLengthInSecondsOnClick, action)
    }
    
    init(_ title: LocalizedStringKey, _ width: CGFloat = Self.DefaultButtonWidth, _ height: CGFloat = Self.DefaultButtonHeight,
         _ showCountDownOfLengthInSecondsOnClick: Int? = nil, _ action: @escaping () -> Void) {
        self.title = title
        self.width = width
        self.height = height
        self.showCountDownOfLengthInSecondsOnClick = showCountDownOfLengthInSecondsOnClick
        self.action = action
        
        if showCountDownOfLengthInSecondsOnClick != nil {
            timerPublisher = Timer.publish(every: 0.25, on: .main, in: .common)
        }
        else {
            timerPublisher = nil
        }
    }

    var body: some View {
        Button(action: self.buttonClicked) {
            GeometryReader { geometry in // needed to fix that otherwise button wasn't clickable on the left and on the right side
                VStack {
                    Spacer()
                    
                    Text(title)
                    
                    Spacer()
                    
                    if lastButtonClick != nil {
                        HStack {
                            ProgressBar($countDown, true)
                            
                            Spacer()
                            
                            Text(presenter.formatDuration(-1 * secondsRemaining, 1)).onReceive(timerPublisher!.autoconnect()) { _ in self.updateCountDown() }
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
    
    
    private func updateCountDown() {
        if let showCountDownOfLengthInSecondsOnClick = showCountDownOfLengthInSecondsOnClick, let lastButtonClick = lastButtonClick {
            let secondsSinceStart = Date().timeIntervalSince(lastButtonClick)
            
            let secondsRemaining = showCountDownOfLengthInSecondsOnClick - Int(secondsSinceStart)
            
            if secondsRemaining >= 0 {
                self.secondsRemaining = secondsRemaining
                self.countDown = CGFloat(secondsRemaining) / CGFloat(showCountDownOfLengthInSecondsOnClick)
                self.didCountDown = false
            }
            else {
                self.didCountDown = true
            }
        }
    }
    
    private func buttonClicked() {
        self.action()
        
        if showCountDownOfLengthInSecondsOnClick != nil {
            lastButtonClick = Date()
            updateCountDown()
        }
    }

}


struct StandardButton_Previews: PreviewProvider {

    static var previews: some View {
        StandardButton("Label") { }
    }

}
