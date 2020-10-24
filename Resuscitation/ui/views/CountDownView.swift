import SwiftUI


struct CountDownView: View {
    
    private var presenter: Presenter
    
    
    private let showCountDownOfLengthInSecondsOnClick: Int32
    
    private var lastButtonClick: Date
    
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    @State private var secondsRemaining: Int = 0
    
    @State private var countDown: CGFloat = 1
    
    @State private var didCountDown: Bool = false
    
    
    init(_ presenter: Presenter, _ lastButtonClick: Date, _ showCountDownOfLengthInSecondsOnClick: Int32) {
        self.presenter = presenter
        self.lastButtonClick = lastButtonClick
        self.showCountDownOfLengthInSecondsOnClick = showCountDownOfLengthInSecondsOnClick
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
        }
        else {
            self.didCountDown = true
        }
    }

}


struct CountDownView_Previews: PreviewProvider {

    static var previews: some View {
        CountDownView(Presenter(ResuscitationPersistence()), Date(), 120)
    }

}
