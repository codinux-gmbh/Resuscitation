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
    
    private let action: () -> Void
    
    
    init(_ title: String, _ action: @escaping () -> Void) {
        self.init(title, Self.DefaultButtonWidth, action)
    }
    
    init(_ title: String, _ width: CGFloat = Self.DefaultButtonWidth, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, nil, action)
    }
    
    init(_ title: String, _ showCountDownOfLengthInSecondsOnClick: Int32? = nil, _ action: @escaping () -> Void) {
        self.init(title, Self.DefaultButtonWidth, showCountDownOfLengthInSecondsOnClick, action)
    }
    
    init(_ title: String, _ width: CGFloat = Self.DefaultButtonWidth,
         _ showCountDownOfLengthInSecondsOnClick: Int32? = nil, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, showCountDownOfLengthInSecondsOnClick, action)
    }
    
    init(_ title: String, _ width: CGFloat = Self.DefaultButtonWidth, _ height: CGFloat = Self.DefaultButtonHeight,
         _ showCountDownOfLengthInSecondsOnClick: Int32? = nil, _ action: @escaping () -> Void) {
        self.title = title.localize()
        self.width = width
        self.height = height
        self.showCountDownOfLengthInSecondsOnClick = showCountDownOfLengthInSecondsOnClick
        self.action = action
    }

    var body: some View {
        Button(action: self.buttonClicked) {
            GeometryReader { geometry in // needed to fix that otherwise button wasn't clickable on the left and on the right side
                VStack {
                    Spacer()
                    
                    Text(title)
                    
                    Spacer()
                    
                    lastButtonClick.map { lastButtonClick in
                        CountDownView(presenter, title, lastButtonClick, showCountDownOfLengthInSecondsOnClick!)
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
            lastButtonClick = Date()
        }
    }

}


struct StandardButton_Previews: PreviewProvider {

    static var previews: some View {
        StandardButton("Label") { }
    }

}
