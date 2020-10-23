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
    
}
