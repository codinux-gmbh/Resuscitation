import SwiftUI


extension View {
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var halfOfScreenWithSpacing: CGFloat {
        return screenWidth / 2 - screenWidth / 20
    }
    

    func hideNavigationBar() -> some View {
        return self
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
    }

    func showNavigationBarTitle(_ title: LocalizedStringKey, displayMode: NavigationBarItem.TitleDisplayMode = .inline) -> some View {
        return self
            .navigationBarHidden(false)
            .navigationBarTitle(title, displayMode: displayMode)
    }
    
    
    func monospaceFont() -> some View {
        return self
            .font(Font.body.monospacedDigit())
    }


    func alignHorizontally(_ alignment: Alignment) -> some View {
        return self.frame(maxWidth: .infinity, alignment: alignment)
    }

    func alignVertically(_ alignment: Alignment) -> some View {
        return self.frame(maxHeight: .infinity, alignment: alignment)
    }


    func makeBackgroundTapable() -> some View {
        return self.background(Color.systemBackground)
    }


    func detailForegroundColor() -> some View {
        return self
            .foregroundColor(Color.secondary)
    }

    func detailFont() -> some View {
        return self
            .font(.callout)
    }

    func styleAsDetail() -> some View {
        return self
            .detailFont()
            .detailForegroundColor()
    }

    func linkForegroundColor() -> some View {
        return self
            .foregroundColor(Color.link)
    }

    func systemGroupedBackground() -> some View {
        return self.background(Color.systemGroupedBackground)
    }

    func removeListInsets() -> some View {
        return self.listRowInsets(EdgeInsets())
    }

    func removeSectionBackground() -> some View {
        return self
            .systemGroupedBackground()
            .removeListInsets()
    }


    func turnAnimationOff() -> some View {
        return self.animation(nil)
    }


    func executeMutatingMethod(_ method: @escaping () -> Void) -> some View {
        let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)

        return self.onReceive(timerPublisher.autoconnect()) { _ in
            timerPublisher.connect().cancel()

            method()
        }
    }
    
}


extension Color {
    static let lightText = Color(UIColor.lightText)
    static let darkText = Color(UIColor.darkText)

    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)

    static let link = Color(UIColor.link)

    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)

    // There are more..

    static var destructive: Color {
        if UIColor.responds(to: Selector(("_systemDestructiveTintColor"))) {
            if let red = UIColor.perform(Selector(("_systemDestructiveTintColor")))?.takeUnretainedValue() as? UIColor {
                return Color(red)
            }
        }

        return Color.red
    }
}


extension Alert.Button {

    static func `default`(_ label: String, _ action: (() -> Void)? = {}) -> Alert.Button {
        return .default(Text(label), action: action)
    }

    static func ok(_ action: (() -> Void)? = {}) -> Alert.Button {
        return .default("OK", action)
    }

    static func discard(_ action: (() -> Void)? = {}) -> Alert.Button {
        return .destructive(Text("Discard"), action: action)
    }

}
